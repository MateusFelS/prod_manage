# ProdManage

Este repositório contém os testes automatizados do aplicativo **ProdManage**, um sistema de controle de estoque para confecções. Os testes foram desenvolvidos utilizando o **Playwright** e estão integrados ao **GitHub Actions** para execução contínua.

## Descrição do Projeto

O projeto visa garantir a qualidade e a confiabilidade das funcionalidades do sistema, proporcionando uma experiência estável e eficiente para os usuários. Com os testes automatizados, conseguimos identificar e corrigir bugs de forma eficiente, reduzindo o tempo de validação e melhorando a entrega de novas funcionalidades.

## Testes Automatizados

- **Ferramenta Utilizada**: Playwright
- **Tipo de Testes**: Testes manuais da interface do usuário e testes automatizados da API
- **Funcionalidades Testadas**: Todas as endpoints da API e interações da interface do usuário no aplicativo.

## Testes de Aceitação Manual

Os testes de aceitação manual são realizados para verificar as funcionalidades do aplicativo em um ambiente real. Eles são essenciais para garantir que todas as interações do usuário estejam funcionando conforme o esperado. 

## Integração Contínua

Os testes estão configurados para serem executados automaticamente sempre que houver uma nova alteração no código, utilizando o **GitHub Actions**. Isso garante que qualquer nova implementação seja testada antes de ser mesclada ao código principal, aumentando a confiança na qualidade do software.

## Como Instalar e Rodar os Testes

### Pré-requisitos

Antes de começar, certifique-se de ter as seguintes ferramentas instaladas em sua máquina:

- [Node.js](https://nodejs.org/) (versão recomendada: 18.x ou superior)  
- [npm](https://www.npmjs.com/) ou [yarn](https://yarnpkg.com/)  
- Git (para clonar o repositório)

### Instalação

1. Clone o repositório:

```bash
git clone https://github.com/seu-usuario/prodmanage-tests.git
cd prodmanage-tests
```

2. Instale as dependências:

```bash
npm install
```
### Executando os Testes

1. Rodar todos os testes automaticamente:

```bash
npx playwright test
```

2. Rodar testes com UI (modo interativo):

```bash
npx playwright test --ui
```

3. Abrir o relatório dos testes (após execução):

```bash
npx playwright show-report
```
