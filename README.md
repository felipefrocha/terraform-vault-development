
# Gestão de credenciais locias com Vault 

---

## Introdução 

Vault é um gerenciador de segredos, credenciais acesso que possibilita centralizar sua autenticação e autorização. 

Podendo ser utilizado como um centralizador de recursos de segurança quando relacionado a provisionamento e gestão de segreddos e credenciais, atuando como um mediador entre um providenciador de identidade e relacionando essa identidade com permissionamento para acesso aos recursos por ele gerenciado. 

### O problema de Credenciais estáticas e locais


Por vezes é necessário em um projeto/cliente gerir mais de um ambiente de Cloud ou ainda mesmo Banco de dados. De forma geral quase todas as CLIs de clouds gerenciam credenciais de pelo menos duas formas:
1. Arquivo de configuração
2. Variáveis de ambientes,

O problema desses formatos é que as credenciais ficam expostas em texto plano, seja no respectivo arquivo de configuração ou ainda no histórico da linha de comando.

Dessa maneira, adversários podem ter acesso a essas credênciais o que pode resultar em um vazamento de informações, provisionamneto de recursos desnecessários, ou alteração/deleção de dados e/ou recursos dos clientes.

### O problema da rotação de credenciais

O desejavel durante o gerenciamento de credenciais e chaves de acesso é que existam formas de substitui-las de maneira simples gerando o mínimo de impacto nos recursos que as consomem. 

Na maioria dos recursos que permitem esse tipo de utilização (como *placeholders* ou referenciados), são tecnologias intimamente ligadas a plataforma que habilitam essa utilização. e.g. AWS KMS and Secret Manager.

Ainda como um grande problema em empresas de desenvolvimento de soluções para terceiros, é que, em ambientes com alguma complexidade ou burocracia para obtenção de credenciais de acesso, costuma-se presenciar o compartilhamento dessas credenciais, expondo o time que o compartilha a problemas notórios:
* turn over do time integrante do projeto
* super utilização de credenciais 
* credenciais genericas e permissivas

Isso dificulta a correta utilização de credenciais com escopos bem definidos, o mapeamento de aplicações que as utilizam e por fim o mais perigoso: antigos membros do projeto com conhecimento dessas credênciais.

### Evitando esse problema

Para evitar esse *vendor lock-in* (ficar preso ao provedor) é recomendado que sejam utilizadas ferramentas, tecnologias, ou técnicas que sejam agnosticas a plataforma. Permitindo assima utilização concorrente ou conjunta e.g. soluções multi-cloud. 

## Proposta de valor

Garantir um processo de desenvolvimento com o gerenciamento seguro de segredos e credenciais com provisionamento de escopo reduzido, com menor tempo de duração e com ciclo de vida conhecido.

## Objetivos do repositório

### Primário

* Encorajar o desenvolvimento com foco em segurança para o time e cliente

### Secundários:

* Habilitar times e equipes  a gerirem seus segredos
* Viabilizar a gestão simplificada do uso de ferramentas de segurança
* Expor a ferramentas da Hashicorp para Devs e DevOps

## Critérios de seleção

Ao escolher uma ferramenta de gestão de segredos, existem alguns aspectos que devem ser levado em consideração, sendo três destes, principais:

1. Técnicas de criptografia suportada.
2. API e integrabilidade
3. Gestão simplificada

Como representantes da Hashicorp no prosente momento da criação dessa solução, a ferramenta escolhida para viabilizar a gestão e provisionamneto de secredos e credenciais será o [Vault](https://vaultproject.io). 


## Considerações

### Setup inicial

Instale:
1. Vault
2. terraform
3. jq 
4. make

Execute a config inicial: `make initial_setup`

### Comunicação com o servidor (Opcional - requer outro setup inicial)

A utilização de SSL e TLS ainda é um problema para diversos desenvolvedores, e pode em muitos momentos complicar o desenvolvimento pelo não entendimento ou ainda a compreensão equivocada de utilização dessa forma de criptografia *in transit*. 

Mesmo com tantos ataques acontecendo e sendo difundidos, diversos de nós arautos da tecnologia ainda insistimos na utilização de protocolos desassegurados, como HTTP puro.

Vault é uma ferramenta de segurança e portanto não faz sentido configura-la para fazer uma acesso inseguro, especialmente no cenário que se propoe esse repositório. Configurar um Vault com um namespace por projeto, ou um por projeto, sendo esse consumido pelos devs.

Autorizar que um snif de rede permita que uma ferramenta robusta como é o vault vaze dados de segurança é uma falha.

Portanto na configuração proposta seguiremos com o mesmo configurado para utilizar TLS e HTTPS.

:warning: OBS: Esse repositório não contém o fluxo mais seguro por usar a versão de `-dev` do Vault, para *setups* mais robustos favor considerar a documentação oficial da Hashicorp para configurações necessárias.


### Configuração de Acesso e provedor de Identidade

É possivel conectar o Vault com diversos provedores de Identidade, sejam elas do tipo [OIDC](https://openid.net/connect/), [SSO](https://www.fortinet.com/resources/cyberglossary/single-sign-on#:~:text=Single%20sign%2Don%20(SSO)%20is%20an%20identification%20method%20that,the%20authentication%20process%20for%20users.) etc.

Abaixo podemos ver um exemplo de como seria a conexão de Vault com openLDAP. A indicação sujerida considera apenas a simplicidade de setup inicial, e apenas é indicado para utilização, caso não seja possivel consumir o  AD)


[Autenticação Métodos]()
```hcl
resource "vault_ldap_auth_backend" "ldap" {
    path        = "local"
    url         = "ldap://localserver.com:3268"
    userdn      = "DC=my,DC=com"
    userattr    = "sAMAccountName"
    upndomain   = "BLA.COM"
    discoverdn  = false
    groupdn     = "DC=my,DC=com"
    # groupattr = "cn"
    groupfilter = "(&(objectClass=group)(member:1.2.840.113556.1.4.1941:={{.UserDN}}))"
}

resource "vault_ldap_auth_backend_group" "group" {
    groupname = "dba"
    policies = [vault_policy.admins.name, "default"]
    backend   = vault_ldap_auth_backend.ldap.path
}
```

### Configuração Vault

< Consult e a documentação >

*  Inicialize o Vault Server: `vault operator init` 
* Copie os certificados pro client e export as mesmas variaveis descritas no *setup*
* Crie um usuário caso não tenha configurado um provedor de identidade
* Faça o deploy da cli: `make deploy_cli`
* Verifique as configurações no diretorio vault:

```bash
cat>>vault/var.auto.tfvars<<EOF
AWS_ACCESS_KEY_ID = ""
AWS_SECRET_ACCESS_KEY = ""
vault_addr = "https://00000"
vault_token = ""
userpass_path = "local"
EOF
```
* `make vault_config`


Faça login pela CLI e utilize os comandos listados no help da mesma para começar a consumir os valores de segredo e credenciais com TTLs.

### Configuração de Credenciais no Terraform usando Vault

```hcl
provider "vault" {
  address = var.vault_addr
  # Auth basend on token This can be ajusted 
  # to use AppRole in a CICD pipeline for example
  auth_login {
    path = "auth/local/login"
    parameters = {
      token = var.vault_token
    }
  }
}

data "vault_aws_access_credentials" "creds" {
  type    = "sts"
  backend = "me"
  role    = format("me-adm-%s", local.env[var.environment])
}

provider "aws" {
  access_key = data.vault_aws_access_credentials.creds.access_key
  secret_key = data.vault_aws_access_credentials.creds.secret_key
  token      = data.vault_aws_access_credentials.creds.security_token

  region     = var.region

  default_tags {
    tags = {
      Builder      = "Terraform"
      Department   = " Labs"
      Application  = "Service Name"
      Project      = "Micro Infra"
      Environment  = local.environment[var.environment]
      CostCenter   = "0001 - TI - CORE"
    }
  }
}

data "vault_generic_secret" "cloudflare" {
  path = "cloudflare/credentials"
}

provider "cloudflare" {
  account_id = data.vault_generic_secret.cloudflare.data["account_id"]
  api_key = data.vault_generic_secret.cloudflare.data["cloudflare_api_key"]
  email = data.vault_generic_secret.cloudflare.data["cloudflare_id"]
}
```
