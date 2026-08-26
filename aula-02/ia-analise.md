# Análise do Uso de IA — Aula 02 TF

## Prompt Utilizado

"Crie um docker-compose.yml para uma aplicação Node.js 20 com Express que usa PostgreSQL 15 como banco de dados e Redis 7 como cache. A API roda na porta 3000. O PostgreSQL precisa de volume nomeado para persistência. Todos os serviços devem estar na mesma rede bridge customizada. Use variáveis de ambiente com interpolação de arquivo .env. Adicione healthchecks, depends_on com condition, restart policy unless-stopped."

## Output Original do Kiro

O Kiro gerou inicialmente um ambiente com três serviços: API Node.js, PostgreSQL e Redis.

O docker-compose.yml original possuía:

- Serviço API construído a partir de um Dockerfile.
- PostgreSQL usando a imagem postgres:15-alpine.
- Redis usando a imagem redis:7-alpine.
- Volume nomeado para PostgreSQL.
- Volume nomeado para Redis.
- Rede bridge customizada chamada app-network.
- Variáveis de ambiente utilizando o arquivo .env.
- depends_on com condition: service_healthy.
- Healthchecks para API, PostgreSQL e Redis.
- Política restart: unless-stopped.

O Kiro também criou inicialmente uma aplicação usando server.js, além do package.json e Dockerfile.

## Alterações que Fiz Manualmente

| O que mudei | Por quê |
|------------|---------|
| Alterei a aplicação para usar app.js | O TF da disciplina especifica app.js como arquivo obrigatório da aplicação Node.js. |
| Ajustei o docker-compose.yml para utilizar a estrutura final do meu projeto | Para manter os arquivos organizados conforme as exigências do TF. |
| Ajustei as variáveis de ambiente | Para utilizar os nomes e valores necessários para a comunicação entre API, PostgreSQL e Redis. |
| Adicionei e configurei o .env.example | O TF exige um modelo das variáveis de ambiente sem expor a senha real. |
| Configurei o .gitignore | Para impedir que o .env e outros arquivos desnecessários sejam versionados. |
| Validei o ambiente com Docker Compose | Para verificar se os três serviços estavam funcionando corretamente. |

## O que o Kiro Acertou

- Criou a estrutura inicial do ambiente com três containers.
- Utilizou PostgreSQL 15 e Redis 7 conforme solicitado.
- Configurou volumes nomeados.
- Criou uma rede bridge personalizada.
- Utilizou healthchecks.
- Configurou depends_on com condições de saúde.
- Utilizou restart: unless-stopped.
- Utilizou variáveis de ambiente.
- Ajudou a acelerar a criação da estrutura inicial do projeto.

## O que o Kiro Errou ou Omitiu

- A aplicação foi criada inicialmente como server.js, enquanto o TF exige app.js.
- Foi necessário adaptar a estrutura gerada para ficar de acordo com os arquivos obrigatórios da atividade.
- Foi necessário validar manualmente as configurações e testar os serviços.
- A IA não substituiu a necessidade de conferir os requisitos do enunciado e testar o ambiente.

## Minha Avaliação

- **Tempo economizado usando IA:** aproximadamente 30 minutos.
- **Tempo gasto validando/corrigindo:** aproximadamente 40 minutos.
- **Nota para o output da IA (1-10):** 8.
- **Usaria novamente para este tipo de tarefa?** Sim. A IA foi útil para criar a estrutura inicial rapidamente, mas é necessário revisar, adaptar e testar o código antes da entrega.