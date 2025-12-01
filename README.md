Projeto SQL — Construindo um Perfil Comportamental de Clientes (Fintech) com SQL

Este repositório contém o código SQL e base de dados utilizado para analisar o comportamento dos clientes ao longo do tempo, aplicando janelas temporais (D7, D15, D30, D60) e métricas que ajudam a identificar padrões de uso, sinais de queda de engajamento, riscos potenciais de churn, rastreamento de produtos e janelas de maior atividade.
Criar uma análise organizada e modular em SQL para explorar o comportamento do cliente ao longo de toda sua jornada.
A estrutura foi construída com CTEs a fim de deixar o fluxo de preparação, limpeza, enriquecimento e cálculo de métricas mais claro e sustentável
O que a análise entrega:
 Atividade histórica completa (lifetime)
Engajamento por períodos recentes (D60, D30, D15, D7)
“Dias desde a última transação” — variavel indpependete  de risco de churn
Produto mais utilizado por cliente em toda a vida e por janelas de tempo
Tabelas pronta para dashboards, modelos estatísticos e aplicação  machine learning 

Tecnologias & Conceitos Utilizados
SQL (SQLite)
CTEs (Common Table Expressions)
Funções de data (julianday, substr)
Window Functions (ROW_NUMBER())
Feature Engineering para métricas de comportamento
Limpeza e estruturação de dados
Explicação Completa no Medium:  https://medium.com/@davidns97/construindo-um-perfil-comportamental-de-clientes-fintech-com-sql-9eb98d50123b
