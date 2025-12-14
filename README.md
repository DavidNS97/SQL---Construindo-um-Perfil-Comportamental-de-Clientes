# Construindo um Perfil Comportamental de Clientes (Fintech) com SQL
<p align="left">
  <img src="https://img.shields.io/badge/SQLite-003B57?style=for-the-badge&logo=sqlite&logoColor=white" alt="SQLite"/>
  <img src="https://img.shields.io/badge/status-concluído-brightgreen?style=for-the-badge" alt="Status: Concluído"/>
</p>

## Contexto e explicação do problema

Nos últimos meses tenho me dedicado com mais profundidade ao estudo de **SQL**, principalmente ao uso de **CTEs** e **Window Functions** para análises mais estruturadas e de melhor desempenho.

Para este projeto escolhi o mercado de **fintech**, uma empresa que oferece diversos serviços financeiros por aplicativo. Mesmo não trabalhando nesse ramo, é um setor com o qual interajo diariamente como consumidor. E justamente por isso tive a ideia de explorar esse tipo de mercado com um olhar analítico, aplicando SQL para entender como os usuários se comportam dentro de uma plataforma financeira.

### 🔎 Perguntas de negócio analisadas
- Transações históricas (vida, D7, D15, D30, D60)  
- Dias desde a última transação  
- Engajamento dos últimos 30 dias versus histórico  
- Idade na base  
- Produto mais usado (em diferentes janelas de tempo)  
- Saldo de pontos atuais  
- Dia da semana mais ativos (nos últimos 60 dias)  
- Período do dia mais ativo (nos últimos 60 dias)  

A partir dessas informações, construí em uma única **view** a tabela com o perfil comportamental dos usuários, utilizando **SQLite** como banco local e desenvolvendo toda a lógica dentro do **VS Code**.

Esse trabalho permite identificar padrões de uso, sinais de queda de engajamento, riscos potenciais de churn, rastreamento de produtos e janelas de maior atividade.  
Essa tabela pode direcionar áreas de **CRM, produto e marketing** para tomar decisões mais assertivas.

## Estrutura das tabelas

Para responder às perguntas de negócio, foram fornecidas **4 tabelas** principais:

### 1. `clientes`
Reúne informações cadastrais básicas do usuário:
- `idCliente` → identificador único do cliente  
- `qtdePontos` → saldo atual de pontos  
- `DtCriacao` → data de entrada na base (usada para calcular idade na base)  

### 2. `produtos`
Tabela de referência com o catálogo de produtos disponíveis:
- `IdProduto` → chave do produto  
- `DescNomeProduto` → nome do produto  
- `DescCategoriaProduto` → categoria do produto  

### 3. `transacoes`
Contém o histórico completo de transações realizadas pelos usuários:
- `IdTransacao` → identificador da transação  
- `IdCliente` → chave para o cliente  
- `DtCriacao` → data da transação  

### 4. `transacao_produto`
Faz a ponte entre transações e produtos utilizados:
- `idTransacaoProduto` → identificador do registro  
- `IdTransacao` → vínculo com a transação  
- `IdProduto` → vínculo com o produto

