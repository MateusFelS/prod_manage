# ProdManage - Documentação do Aplicativo

## Sumário

1. [Introdução](#introdução)
2. [Funcionalidades Principais](#funcionalidades-principais)
3. [Tecnologias Utilizadas](#tecnologias-utilizadas)
4. [Instalação e Configuração](#instalação-e-configuração)
5. [Endpoints da API](#endpoints-da-api)
6. [Testes](#testes)
7. [Considerações Finais](#considerações-finais)

---

## Introdução

O **ProdManage** é um aplicativo voltado para a gestão de cortes de produção e o monitoramento de desempenho de funcionários em uma linha de produção. Ele permite registrar, acompanhar e visualizar o status dos cortes, além de oferecer relatórios sobre a produção dos funcionários, incluindo metas e eficiência.

O objetivo principal é otimizar o processo de produção, oferecendo uma ferramenta simples para gerenciar e monitorar o progresso de tarefas, garantindo que as metas de produção sejam atingidas.

## Funcionalidades Principais

1. **Cadastro de Cortes de Produção**
   - Permite o registro de novos cortes de produção, incluindo informações como código, linha de produção, fornecedor, quantidade de peças e data limite.
   - Upload de imagem do corte.

2. **Gestão de Status de Cortes**
   - Atualização do status dos cortes (Em progresso, Pausado, Adiado, Finalizado).
   - Exclusão de cortes.

3. **Monitoramento de Produção de Funcionários**
   - Registro de desempenho dos funcionários.
   - Monitoramento de produção por hora, com cálculo de metas (100%, 80%, 70%).
   - Destaque visual para a eficiência do funcionário (verde para produção ideal, vermelho para abaixo do esperado).

4. **Relatórios de Desempenho**
   - Geração de relatórios diários, semanais e mensais de produção e corte.
   - Visualização de histórico e desempenho dos funcionários.

## Tecnologias Utilizadas

- **Frontend**: Flutter
- **Backend**: NestJS
- **Banco de Dados**: Prisma (MySQL)
- **Upload de Imagens**: Multer
- **Testes**: Ruby Cucumber, HTTParty

## Instalação e Configuração

### Backend

1. Clone o repositório:
   ```bash
   git clone https://github.com/MateusFels/prod_manage-backend.git
   cd prod_manage-backend

2. Instale as dependências:
   ```bash
   npm install

3. Crie o arquivo .env com as seguintes variáveis:
   ```bash
   DATABASE_URL="mysql://root:@localhost:3306/db_prod_manage"

4. Rode as migrações do banco de dados:
   ```bash
   npx prisma migrate dev

5. Inicie o servidor:
   ```bash
   npm run start

### Frontend

1. Clone o repositório:
   ```bash
    git clone https://github.com/MateusFels/prod_manage_app.git
    cd prod_manage_app

2. Instale as dependências do Flutter:
   ```bash
    flutter pub get

3. Inicie o aplicativo:
   ```bash
    flutter run

## Endpoints da API

### Autenticação

* **GET** `/users`
  * Parâmetros: `{ token: string, password: string }`
  * Descrição: Recebe acesso ao aplicativo.

### Cortes de Produção

* **GET** `/cut-records`
  * Descrição: Retorna todos os cortes de produção.

* **POST** `/cut-records`
  * Parâmetros: `{ code: string, supplier: string, line1: string, line2?: string, comment?: string, limiteDate: string }`
  * Descrição: Cria um novo corte de produção.

* **PATCH** `/cut-records/:id`
  * Parâmetros: `{ status: string }`
  * Descrição: Atualiza o status de um corte de produção.

* **DELETE** `/cut-records/:id`
  * Descrição: Exclui um corte de produção.

* **POST** `/cut-records/:id/upload-image`
  * Parâmetros: `image: file`
  * Descrição: Faz o upload de uma imagem para o corte.

### Funcionários

* **GET** `/employees`
  * Descrição: Retorna todos os funcionários.

* **POST** `/employees`
  * Parâmetros: `{ name: string, role: string, entryDate: DateTime }`
  * Descrição: Cria um novo funcionário.

* **GET** `/employees/:id`
  * Descrição: Retorna os detalhes de um funcionário específico.

* **DELETE** `/employees/:id`
  * Descrição: Exclui um funcionário.

### Performance

* **GET** `/performances`
  * Descrição: Retorna todos os registros de performance dos funcionários.

* **POST** `/performances`
  * Parâmetros: `{ employeeId: number, produced: number, goal: number, schedule: string }`
  * Descrição: Cria um novo registro de performance para um funcionário.

* **PATCH** `/performances/:id`
  * Parâmetros: `{ produced: number, goal: number }`
  * Descrição: Atualiza um registro de performance.

* **DELETE** `/performances/:id`
  * Descrição: Exclui um registro de performance.

### Cargos

* **GET** `/roles`
  * Descrição: Retorna todos os cargos disponíveis.

* **POST** `/roles`
  * Parâmetros: `{ title: string, description: string }`
  * Descrição: Cria um novo cargo.

* **GET** `/roles/:id`
  * Descrição: Retorna os detalhes de um cargo específico.

* **DELETE** `/roles/:id`
  * Descrição: Exclui um cargo.

### Registros de Operação

* **GET** `/operation-records`
  * Descrição: Retorna todos os registros de operação.

* **POST** `/operation-records`
  * Parâmetros: `{ cutType: string, operationName: string, calculatedTime: string }`
  * Descrição: Cria um novo registro de operação.

* **GET** `/operation-records/:id`
  * Descrição: Retorna os registros de uma operação específica.

* **DELETE** `/operation-records/:id`
  * Descrição: Exclui um registro de operação.

## Testes
Os testes são feitos utilizando Ruby Cucumber e HTTParty para testes de API e Testes manuais para o front-end. Os testes estão na pasta `prod_manage_QA`.

## Considerações Finais
O ProdManage visa fornecer uma solução simples e eficaz para o gerenciamento de produção, especialmente em cenários de linha de produção. Com foco na eficiência e monitoramento contínuo, o sistema ajuda a garantir que as metas de produção sejam atingidas e facilita o acompanhamento de desempenho dos funcionários.