# Aula 03 — Terraform + IAM | Carollini Godoy (RA 3925000)

## Design da Estrutura IAM

A estrutura IAM da TechNova foi criada utilizando Terraform para permitir que a infraestrutura seja definida como código, facilitando a padronização, repetibilidade, manutenção e auditoria das configurações.

Foram criados dois grupos com responsabilidades diferentes:

* `3925000-technova-developers`: grupo destinado aos desenvolvedores, com acesso de leitura aos buckets S3 da TechNova.
* `3925000-technova-platform-eng`: grupo destinado aos engenheiros de plataforma, com permissões para consultar, iniciar e parar instâncias EC2 da TechNova, além de ler e escrever objetos no S3.

Também foram criados três usuários:

* `3925000-juliana-dev`: pertence ao grupo developers.
* `3925000-rafael-platform`: pertence aos grupos developers e platform-eng.
* `3925000-lucas-intern`: pertence ao grupo developers.

A separação por grupos evita atribuir permissões individualmente aos usuários e facilita o gerenciamento das responsabilidades.

---

## Custom Policies

Foram criadas três policies personalizadas.

### S3 Read

A policy `3925000-technova-s3-read` permite:

* `s3:GetObject`
* `s3:ListBucket`

O acesso é limitado aos recursos que seguem o padrão `technova-*`.

### EC2 + S3 Full

A policy `3925000-technova-ec2-s3-full` permite consultar informações de instâncias EC2 e iniciar ou parar instâncias somente quando elas possuem a tag:

`Project=TechNova`

Também permite operações de leitura e escrita no S3 dentro dos recursos `technova-*`.

### Deny Destructive

A policy `3925000-technova-deny-destructive` possui um Deny explícito para ações destrutivas, incluindo operações de Delete, Terminate e exclusão de recursos IAM.

O Deny explícito prevalece sobre permissões Allow e funciona como uma camada adicional de proteção.

---

## Princípio do Menor Privilégio

O princípio do menor privilégio consiste em conceder a cada usuário, grupo ou serviço somente as permissões necessárias para executar suas funções, evitando acessos excessivos.

Neste projeto, esse princípio foi aplicado de várias formas.

**Exemplo 1:** os desenvolvedores não recebem acesso administrativo ao S3. Eles possuem somente `GetObject` e `ListBucket`, suficientes para consultar os dados.

**Exemplo 2:** as operações de `StartInstances` e `StopInstances` são protegidas por uma `Condition` que exige a tag `Project=TechNova`. Dessa forma, o acesso não é aplicado indiscriminadamente a qualquer instância EC2.

Outro exemplo é a policy de Deny explícito, que impede ações destrutivas mesmo que outra policy conceda uma permissão Allow.

Se fosse utilizada a policy gerenciada `AmazonS3FullAccess`, os usuários receberiam permissões muito mais amplas do que as necessárias, incluindo operações de criação, alteração e exclusão de objetos e buckets. Isso aumentaria o impacto de erros humanos ou de credenciais comprometidas.

---

## Diagrama de Permissões

```text
                    ┌──────────────────────────┐
                    │        IAM USERS         │
                    ├──────────────────────────┤
                    │ Juliana                  │
                    │ Rafael                   │
                    │ Lucas                    │
                    └────────────┬─────────────┘
                                 │
                                 ▼
                    ┌──────────────────────────┐
                    │        IAM GROUPS        │
                    ├──────────────────────────┤
                    │ developers               │
                    │ platform-eng             │
                    └────────────┬─────────────┘
                                 │
                ┌────────────────┼────────────────┐
                ▼                ▼                ▼
         ┌─────────────┐ ┌─────────────┐ ┌──────────────┐
         │ S3 Read     │ │ EC2 + S3    │ │ Deny         │
         │ Policy      │ │ Full Policy │ │ Destructive  │
         └──────┬──────┘ └──────┬──────┘ └──────────────┘
                │                │
                ▼                ▼
             S3 Data        EC2 + S3 Data


                    SERVICE ROLE
                         │
                         ▼
             ┌──────────────────────┐
             │ EC2 Instance Profile │
             └──────────┬───────────┘
                        │
                        ▼
             ┌──────────────────────┐
             │   EC2 Service Role   │
             │ 3925000-technova-    │
             │ ec2-role             │
             └──────────┬───────────┘
                        │
                        ▼
                  S3 Read / Write
                        │
                        ▼
              technova-app-data-*
```

---

## EC2 Service Role

Foi criada a role:

`3925000-technova-ec2-role`

A role possui uma política de confiança permitindo que o serviço EC2 assuma a role.

Também foi criado o Instance Profile:

`3925000-technova-ec2-profile`

A role permite que uma instância EC2 tenha acesso de leitura e escrita aos recursos S3 que seguem o padrão:

`technova-app-data-*`

Essa abordagem evita armazenar credenciais AWS diretamente dentro da instância EC2.

---

## Estrutura dos Arquivos

```text
aula-03/
├── .gitignore
├── main.tf
├── outputs.tf
├── policies.tf
├── providers.tf
├── roles.tf
├── variables.tf
├── README.md
└── terraform-plan-output.txt
```

### Descrição dos arquivos

* `providers.tf`: configuração do Terraform e provider AWS.
* `main.tf`: criação dos usuários, grupos e associações.
* `policies.tf`: criação das policies personalizadas e seus attachments.
* `roles.tf`: criação da EC2 Service Role, política de acesso ao S3 e Instance Profile.
* `variables.tf`: variáveis utilizadas no projeto.
* `outputs.tf`: informações retornadas após a criação dos recursos.
* `terraform-plan-output.txt`: registro do resultado do `terraform plan`.
* `README.md`: documentação da solução.

---

## Tags

Os recursos compatíveis com tags utilizam informações padronizadas do projeto:

```text
Project    = "TechNova"
ManagedBy  = "Terraform"
Aluno      = "Carollini Godoy"
RA         = "3925000"
Disciplina = "DevOps - UniFAAT 2026-2"
Aula       = "03"
```

A padronização facilita a identificação, organização e gerenciamento dos recursos.

---

## Como Executar

O projeto deve ser executado no AWS Academy Learner Lab com credenciais temporárias válidas.

### 1. Inicializar o Terraform

```bash
terraform init
```

### 2. Formatar os arquivos

```bash
terraform fmt
```

### 3. Validar a configuração

```bash
terraform validate
```

O resultado esperado é:

```text
Success! The configuration is valid.
```

### 4. Criar o plano

```bash
terraform plan
```

Para salvar o resultado do plano:

```powershell
terraform plan 2>&1 | Tee-Object -FilePath terraform-plan-output.txt
```

O plano deste projeto apresentou:

```text
Plan: 17 to add, 0 to change, 0 to destroy.
```

### 5. Aplicar a infraestrutura

```bash
terraform apply
```

Após revisar o plano, confirmar com:

```text
yes
```

### 6. Destruir os recursos após os testes

```bash
terraform destroy
```

Essa etapa é importante para evitar a permanência desnecessária de recursos no ambiente AWS.

---

## Execução no AWS Academy

Durante a execução no AWS Academy Learner Lab, o comando `terraform plan` foi executado com sucesso e identificou os 17 recursos previstos para criação.

Entretanto, durante o `terraform apply`, o ambiente apresentou erros `AccessDenied` relacionados às permissões IAM da role `voclabs`.

Entre as ações bloqueadas estão:

```text
iam:CreateUser
iam:CreateGroup
iam:CreateRole
iam:TagPolicy
```

A investigação das permissões mostrou que a role `voclabs` possui as policies `Pvoclabs1` e `Pvoclabs2`, e que existe um bloqueio explícito relacionado à policy `Pvoclabs2`.

A simulação de permissões também retornou `implicitDeny` para as ações necessárias à criação dos recursos IAM.

Portanto, o bloqueio ocorreu devido às permissões disponíveis no ambiente AWS Academy, e não devido a erro de sintaxe ou validação da configuração Terraform.

---

## Comandos Utilizados

```bash
terraform fmt
terraform validate
terraform plan
terraform apply
terraform destroy
```

Comandos utilizados para verificar as credenciais e permissões AWS:

```bash
aws sts get-caller-identity
aws iam list-attached-role-policies --role-name voclabs
aws iam simulate-principal-policy --policy-source-arn arn:aws:iam::ACCOUNT_ID:role/voclabs --action-names iam:CreateUser iam:CreateGroup iam:CreateRole iam:TagPolicy
```

---

## Reflexão

A atividade demonstrou como o Terraform pode ser utilizado para automatizar a criação e o gerenciamento de recursos IAM, permitindo que usuários, grupos, policies e roles sejam definidos como código.

Um dos principais aprendizados foi a importância do princípio do menor privilégio. Em vez de conceder permissões administrativas amplas, as permissões devem ser limitadas às necessidades de cada função.

Também foi possível compreender a diferença entre permissões Allow e Deny explícito. Um Deny explícito funciona como uma camada de segurança adicional e prevalece sobre permissões Allow.

Outro aprendizado importante foi que a infraestrutura como código depende não apenas da configuração correta dos arquivos, mas também das permissões disponíveis na conta AWS. Mesmo com uma configuração Terraform válida e um plano gerado corretamente, o `apply` pode ser impedido pelas políticas de segurança do ambiente.

Dessa forma, o uso combinado de Terraform, IAM e princípio do menor privilégio contribui para uma infraestrutura mais organizada, auditável, segura e previsível.
