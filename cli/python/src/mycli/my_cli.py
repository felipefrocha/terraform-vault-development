from secrets import choice
from builtins import Exception, FileExistsError
import os, sys
import argparse
import configparser
import logging
import hvac


LOG_STRUCTURE = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
VAULT_ADDR = (
    os.environ["VAULT_ADDR"]
    if os.getenv("VAULT_ADDR")
    else "http://localhost:8200"
)
PATH = os.path.join(os.path.expanduser("~"), ".vault_token")
VERSION = "0.0.2"
REGION = 'us-east-1'
RDS_PORT = {
    "dev": 5492,
    "stg": 5493,
    "prd": 5494,
}

class mycli:
    CLI_VERSION = f"MY CLI {VERSION}"
    INI_FILE = "compilado.ini"

    def __set_token(self, token):
        with open(PATH, "w") as file:
            file.write(token)

    def __delete_token(self, token):
        with open(PATH, "w") as file:
            file.write(token)

    def __get_token(self):
        token = None
        if not os.path.isfile(PATH):
            return None

        path_config_file = PATH
        with open(path_config_file, "r") as file:
            token = file.read()

        return token

    def __init__(self):
        # if self.__load_ini_file(self.INI_FILE):
        self.__vault_adapter = hvac.adapters.RawAdapter(
            base_uri=VAULT_ADDR,
            token=self.__get_token(),
            cert=None,
            verify=True,
            timeout=30,
            proxies=None,
            allow_redirects=True,
            session=None,
            namespace=None,
            ignore_exceptions=False,
            strict_http=False,
            request_header=True,
        )
        self.__run()

    def __run(self):
        self.parser = argparse.ArgumentParser(
            prog="my",
            description="Automation for MY Developer team",
            epilog="Author: Felipe F. Rocha",
            usage="%(prog)s [options]",
        )

        self.parser.version = self.CLI_VERSION
        self.parser.add_argument("-v", "--version", action="version")

        subparsers = self.parser.add_subparsers(
            dest="command", help="MY Credentials provider"
        )

        self.__login(subparsers)
        self.__creds(subparsers)
        self.__bastion(subparsers)

        parser_args = self.parser.parse_args()

        if parser_args:
            try:
                self._command_select(str(parser_args.command), args=parser_args)
            except Exception as e:
                print("Argumento inválido: {}".format(e))
                sys.exit(1)
        else:
            self.parser.print_help()
            sys.exit(1)

    def __login(self, subparsers):
        self.login_parser = subparsers.add_parser("login", help="Login into Vault")
        self.login_parser.add_argument(
            "username", help="Native User and Passowrd Login", type=str
        )
        self.login_parser.add_argument(
            "password", help="Native User and Passowrd Login", type=str
        )

    def __creds(self, subparsers):
        self.credentials_parser = subparsers.add_parser(
            "my-aws", help="Get Credentials from Vault"
        )

        self.credentials_parser.add_argument(
            "credential",
            help="Credential Required",
            type=str,
            choices=["ds", "de", "adm"],
        )

        self.credentials_parser.add_argument(
            "environment", help="Environment", type=str, choices=["dev", "prd", "stg"]
        )

    def __bastion(self, subparsers):
        self.bastion_parser = subparsers.add_parser(
            "bastion-rds", help="Fowarding port to RDS throughout Bastion"
        )

        self.bastion_parser.add_argument(
            "environment", help="Environment", type=str, choices=["dev", "prd", "stg"]
        )

    def __vault_login(self, username: str, password: str) -> dict:
        # vault_auth_ldap = hvac.api.auth_methods.Ldap(self.__vault_adapter)
        vault_auth_userpass = hvac.api.auth_methods.Userpass(self.__vault_adapter)
        auth = None

        try:
            auth = vault_auth_userpass.login(
                username, password, use_token=True, mount_point="local"
            )
        except Exception as ex:
            print(f"{username} login failed")
            self.__delete_token("")
            raise Exception(f"{ex}")

        self.__set_token(dict(auth.json()).get("auth").get("client_token"))
        print(f"{username} is Logged")

    def __vault_aws_creds(self, name: str, env: str = "dev"):
        vault_se_aws = hvac.api.secrets_engines.Aws(self.__vault_adapter)
        response_creds = vault_se_aws.generate_credentials(
            f"{name}",
            role_arn=None,
            ttl=3600,
            endpoint="sts",
            mount_point=f"me",
        )
        creds = response_creds.json().get("data")
        region = REGION
        output = f"""
export AWS_ACCESS_KEY_ID={creds.get("access_key")}
export AWS_SECRET_ACCESS_KEY={creds.get("secret_key")}
export AWS_SESSION_TOKEN={creds.get("security_token")}
"""
        with open(
            os.path.join(os.path.expanduser("~"), ".aws/credentials"), "w"
        ) as file:
            file.write(
                f"""
[default]
aws_access_key_id={creds.get("access_key")}
aws_secret_access_key={creds.get("secret_key")}
aws_session_token={creds.get("security_token")}

"""
            )
        with open(
            os.path.join(os.path.expanduser("~"), ".aws/config"), "w"
        ) as file:
            file.write(
                f"""
[default]
region = {region}
output = json
"""
            ) 

        print(output)

    def __redirect_bastion(self, env: str = "dev"):
        import paramiko
        from mycli.foward import forward_tunnel
        import boto3
        from botocore.config import Config

        awssdk_config = Config(
            region_name = 'us-east-2',
            signature_version = 'v4',
            retries = {
                'max_attempts': 10,
                'mode': 'standard'
            }
        )

        rds_client = boto3.client("rds",config=awssdk_config)
        ec2_client = boto3.client("ec2",config=awssdk_config)
        rds_host = None
        try:
            rds_instance = rds_client.describe_db_instances(
                DBInstanceIdentifier=f"wingg-rds-{env}"
            )
            remote_host = rds_instance.get("DBInstances")[0].get("Endpoint").get("Address")
        except Exception as exrds:
            if env != 'prd': raise exrds
            # TODO - Change how to get those names
            rds_instance = rds_client.describe_db_proxy_endpoints(
                DBProxyName='wingg-aur-prod-cluster',
                Filters=[
                    {
                        'Name': 'db-cluster-endpoint-type',
                        'Values': [
                            'writer',
                        ]
                    },
                ]
            )
            remote_host = rds_instance.get("DBProxyEndpoints")[0].get("Endpoint")
            

        # print(remote_host)
        remote_port = 5432

        local_port = RDS_PORT.get(env)

        bastion_instance = ec2_client.describe_instances(
            Filters=[
                {
                    "Name": "tag:Name",
                    "Values": [
                        f"bastion-infra-{env}",
                    ],
                },
            ],
        )

        ssh_host = (
            bastion_instance.get("Reservations")[0]
            .get("Instances")[0]
            .get("PublicIpAddress")
        )
        # print(ssh_host)
        ssh_port = 22

        user = "ubuntu"

        home = os.path.expanduser("~")

        transport = paramiko.Transport((ssh_host, ssh_port))
        transport.connect(
            hostkey=None,
            username=user,
            pkey=paramiko.RSAKey.from_private_key_file(
                f"{home}/.ssh/terraform_wingg_{env}"
            ),
        )

        try:
            print(
                f"""
                Using Bastion: {ssh_host} 
                Connecting to DB: {remote_host}
                Accessible throughout:  localhost:{local_port}
                """
            )
            forward_tunnel(local_port, remote_host, remote_port, transport)
        except KeyboardInterrupt:
            print("Port forwarding stopped.")
            sys.exit(0)
        except Exception as ex:
            print("Fowarding ERROR.")
            traceback.print_exc()
            sys.exit(1)

    def _command_select(self, command: str, args):
        if command == "login":
            self.__vault_login(username=args.username, password=args.password)
        elif command == "my-aws":
            self.__vault_aws_creds(
                name=f"wingg-{args.credential}", env=args.environment
            )
        elif command == "bastion-rds":
            self.__redirect_bastion(env=args.environment)
        else:
            raise Exception("Error")


def main():
    mycli()


if __name__ == "__main__":
    main()
