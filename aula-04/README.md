# Infraestrutura TechNova — Aula 04

## Objetivo

Implementar, com Terraform, uma infraestrutura AWS para a TechNova utilizando uma VPC com múltiplas zonas de disponibilidade, sub-redes públicas e privadas, Security Groups e uma instância EC2 executando uma API Node.js.

A infraestrutura foi criada na região `us-east-1` utilizando recursos gerenciados pelo Terraform.

## Arquitetura

```text
                         Internet
                            |
                     Internet Gateway
                            |
                 +----------------------+
                 |      TechNova VPC     |
                 |      10.0.0.0/16      |
                 +----------------------+
                    /                  \
                   /                    \
          Availability Zone A      Availability Zone B
               us-east-1a              us-east-1b
                   |                       |
          +----------------+      +----------------+
          | Public Subnet  |      | Public Subnet  |
          | 10.0.1.0/24    |      | 10.0.3.0/24    |
          +----------------+      +----------------+
                   |                       |
              EC2 Node.js
              TechNova API

          +----------------+      +----------------+
          | Private Subnet |      | Private Subnet |
          | 10.0.2.0/24    |      | 10.0.4.0/24    |
          +----------------+      +----------------+
                   \                       /
                    \                     /
                     Private Route Table
```

## Recursos criados

| Recurso                 | Descrição                                |
| ----------------------- | ---------------------------------------- |
| VPC                     | `10.0.0.0/16`                            |
| Subnets públicas        | `10.0.1.0/24` e `10.0.3.0/24`            |
| Subnets privadas        | `10.0.2.0/24` e `10.0.4.0/24`            |
| Internet Gateway        | Acesso das subnets públicas à Internet   |
| Route Table pública     | Rota `0.0.0.0/0` para o Internet Gateway |
| Route Table privada     | Sem rota direta para a Internet          |
| Security Group API      | SSH/22 e API/3000                        |
| Security Group Database | PostgreSQL/5432 somente dentro da VPC    |
| EC2                     | Amazon Linux 2023, `t2.micro`            |
| Key Pair                | `technova-key`                           |
| IAM Instance Profile    | `LabInstanceProfile`                     |
| API                     | Node.js na porta `3000`                  |

## Pré-requisitos

* Terraform instalado
* AWS CLI instalado
* Conta AWS Academy / Learner Lab
* Credenciais temporárias do AWS Academy configuradas
* Git instalado
* Chave SSH em:

```text
~/.ssh/technova-key
~/.ssh/technova-key.pub
```

* Repositório da API disponível no GitHub:

```text
https://github.com/caroll143/technova-api
```

## Estrutura do projeto

```text
aula-04/
├── ec2.tf
├── iam.tf
├── main.tf
├── network.tf
├── outputs.tf
├── providers.tf
├── security.tf
├── variables.tf
├── README.md
├── evidencia-plan.txt
├── evidencia-api.json
└── evidencia-ssh.txt
```

## Inicialização

Dentro da pasta `aula-04`:

```powershell
terraform init
```

## Validação

```powershell
terraform fmt
terraform validate
```

## Planejamento

```powershell
terraform plan
```

Para gerar a evidência:

```powershell
terraform plan > evidencia-plan.txt
```

## Aplicação

```powershell
terraform apply
```

Após a criação da infraestrutura, os outputs apresentam o ID da VPC, IDs das subnets, Security Groups, IP público da EC2, URL da API e comando SSH.

## Teste da API

A API é executada na porta `3000`.

Teste a rota principal:

```powershell
Invoke-RestMethod http://IP_PUBLICO:3000
```

Teste o health check:

```powershell
Invoke-RestMethod http://IP_PUBLICO:3000/health
```

Resultado esperado:

```text
GET /
message : TechNova API
status  : running
```

```text
GET /health
status : healthy
```

A evidência dos testes está registrada em:

```text
evidencia-api.json
```

## Acesso SSH

O acesso à EC2 pode ser realizado com:

```powershell
ssh -i "$HOME\.ssh\technova-key" ec2-user@IP_PUBLICO
```

A evidência do acesso está registrada em:

```text
evidencia-ssh.txt
```

## User Data

A EC2 é configurada automaticamente pelo Terraform utilizando User Data.

O script:

1. Atualiza os pacotes do sistema;
2. Instala o Git;
3. Instala o Node.js 18;
4. Clona o repositório `technova-api`;
5. Executa `npm install`;
6. Inicia a API Node.js na porta `3000`.

A API é configurada para escutar em `0.0.0.0:3000`, permitindo o acesso externo através do Security Group.

## Security Groups

### API

Portas liberadas:

* TCP `22` — SSH
* TCP `3000` — API

O tráfego de saída é permitido.

### Database

Porta liberada:

* TCP `5432`

O acesso é permitido somente a partir do CIDR da VPC:

```text
10.0.0.0/16
```

O tráfego de saída é permitido.

## Decisões técnicas

A infraestrutura foi dividida em subnets públicas e privadas distribuídas entre duas Availability Zones.

As subnets públicas possuem `map_public_ip_on_launch = true` e utilizam uma route table com acesso ao Internet Gateway.

As subnets privadas não possuem rota direta para a Internet, mantendo uma separação lógica entre recursos públicos e privados.

Para a instância EC2 foi utilizado o `t2.micro`, conforme especificação da atividade, com Amazon Linux 2023.

Como o ambiente utilizado é o AWS Academy Learner Lab, foi utilizado o `LabInstanceProfile` disponibilizado pelo ambiente acadêmico para a associação da instância EC2 ao perfil IAM.

A opção `user_data_replace_on_change = true` foi utilizada para garantir que alterações no User Data provoquem a recriação da instância e permitam a execução do script de inicialização atualizado.

## Evidências

Os arquivos de evidência são:

* `evidencia-plan.txt` — resultado do Terraform Plan;
* `evidencia-api.json` — testes das rotas `/` e `/health`;
* `evidencia-ssh.txt` — evidência de acesso à EC2.

O Terraform Plan final apresentou:

```text
No changes. Your infrastructure matches the configuration.
```

## Destruição da infraestrutura

Após a conclusão da validação e coleta das evidências, os recursos devem ser removidos para evitar custos:

```powershell
terraform destroy
```

Confirme digitando:

```text
yes
```

Após o `destroy`, confirme que não existem recursos da atividade permanecendo ativos no ambiente AWS Academy.

## Autor

**Carollini Godoy**

**RA:** 3925000

**Disciplina:** DevOps

**Projeto:** TechNova — Aula 04
