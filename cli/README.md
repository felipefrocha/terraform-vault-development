## CLI de projeto/cliente/empresa

Para facilitar o uso de Vault, e possivelmente outras ferramentas que forem adicionadas ao longo do projeto se faz necessário implementar uma interface que facilite o consumo dessas ferramentas.

É imprecindível a equipe de DevOps e SRE entender que não é a principal função dos demais integrantes do time ficar aprendendo o ferramental adotado por esses profissionais.

Mesmo tendo que considerar mitigar duvidas técnicas dos demais membros do projeto sobres ferramentas adotadas, não deve ser um impecilio para a adoção do *workflow* proposto, as diversas interfaces com ferramentas distintas.

Portanto deve-se sempre considerar como será a experiência do desenvolvedor para minimizar o impacto da adoção das boas práticas propostas.

### Requisitos
Obrigatórios:
- python >= 3.8
- pip3 >= 22
- awscli v2
Opcionais:
- Make

### Instalação 
Para instalação pelo codigo fonte é necessário que o Make esteja instalado.

```bash
$ make cli
```


### Utilização

Uma vez instalado é possível utilizar a CLI apenas pelo terminal.

Comando de *help* pode ser utilizado para cada subcomando.

```bash
# Exemplo help da raiz
$ mycli -h
usage: my [options]

Automation for My Developer team

positional arguments:
  {login,my-aws,bastion-rds}
                        My Credentials provider
    login               Login into Vault
    my-aws             Get Credentials from Vault
    bastion-rds         Fowarding port to RDS throughout Bastion

optional arguments:
  -h, --help            show this help message and exit
  -v, --version         show program's version number and exit

Author: Felipe F. Rocha
```

#### Login

Esse comando deve ser realizado sempre para que o Vault se torne acessível.
Será armazenado um token com validade de até 8h a partir de sua execussão, o mesmo será armazenado na pasta de usuário como um arquivo oculto.
Não sendo necessário estar cifrado por sua curta duração.

```bash
$ mycli login -h
usage: my [options] login [-h] username password

positional arguments:
  username    Native User and Passowrd Login
  password    Native User and Passowrd Login

optional arguments:
  -h, --help  show this help message and exit
```

**Exemplo:** `mycli login felipe "senha"` 
Utilize aspas duplas na senha caso a mesma tenha caracteres especiais, 
mas verifique que alguns são reservados como o *scape* `\` sendo necessário ajustes.

#### Credenciais de AWS Dinamicas
Esse comando configura localmente sua `awscli` com um perfil `default`

*OBS:* :warning: Salve o arquivo `~/.aws/credentials` se tiver alguma configuração pre-existente, uma vez que x `mycli` irá invariavelmente substituí-lo.

```bash
$ mycli my-aws -h
usage: my [options] my-aws [-h] {ds,de,adm} {dev,prd,stg}

positional arguments:
  {ds,de,adm}    Credential Required
  {dev,prd,stg}  Environment

optional arguments:
  -h, --help     show this help message and exit
```

**Exmeplo:**
`mycli my-aws adm dev`

**_OBS:_** Nesse momento só temos as roles de `adm` que consiste em uma conta administradora. 
:waring: **Por favor cuidado!**

#### SSH para instâncias do RDS

Nesse momento apenas as instancias de `dev` e `stg` podem ser acessáda por essa ferramenta.

Isso é para garantir que o banco acessível por todos os desenvolvedores não tenha imapcto nos clientes e dessa forma garantir sua proteção, deixando apenas os demais desenvolvedores autorizados a realizar essa operação.

A conexão é buscada e mantida pela cli, dessa forma o dev apenas precisa apontar o ambiente de acesso desejado, e também é possível acessar multiplas bases simultaneamente.

O comando é bloqueante nesse momento para garantir que se x desenvolvedorx encerrar a sessão de contexto do comando a conexão seja desfeita.

Importante destacar que o Fowarding aqui utilizado não é de autoria do desenvolvedor, foi um código aproveitado da base do `paramiko`.

```bash
$ mycli bastion-rds -h
usage: my [options] bastion-rds [-h] {dev,prd,stg}

positional arguments:
  {dev,prd,stg}  Environment

optional arguments:
  -h, --help     show this help message and exit
```

Exemplo:
```bash
$ mycli bastion-rds dev

                Using Bastion: 127.0.1.1 
                Connecting to DB: rds-dev.chablau.br-alias-3.rds.amazonaws.com
                Accessible throughout:  localhost:0000
```
