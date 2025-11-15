-- ============================================
-- 📌 Construção da Tabela Única com Perfil Comportamental dos Clientes
-- Data de referência da análise: 11/08/2025
-- ============================================

WITH 

-- ======================================================
-- CTE 1: Base de transações tratada com datas e métricas
-- ======================================================
tb_transacao AS (
    SELECT 
        IdCliente,
        IdTransacao,
        substr(DtCriacao, 1, 10) AS dt_criacao,

        -- Diferença em dias entre a data de análise e a data da transação
        julianday('2025-08-11') - julianday(substr(DtCriacao, 1, 10)) AS dif_date,

        -- Hora da transação como inteiro (para análise de períodos do dia)
        CAST(strftime('%H', substr(DtCriacao, 1, 19)) AS INTEGER) AS hora       

    FROM transacoes
    WHERE dt_criacao <= '2025-08-11'
),

-- ======================================================
-- CTE 2: Sumário de transações por cliente
-- ======================================================
tb_sumario_transacao AS (
    SELECT
        IdCliente,

        -- Quantidade total de transações (vida)
        COUNT(IdTransacao) AS Qtd_transacoes_vida,

        -- Quantidade de transações por janela de tempo
        COUNT(CASE WHEN dif_date <= 60 THEN IdTransacao END) AS Qtd_transacoes_D60,
        COUNT(CASE WHEN dif_date <= 30 THEN IdTransacao END) AS Qtd_transacoes_D30,
        COUNT(CASE WHEN dif_date <= 15 THEN IdTransacao END) AS Qtd_transacoes_D15,
        COUNT(CASE WHEN dif_date <= 7  THEN IdTransacao END) AS Qtd_transacoes_D7,

        -- Dias desde a última transação
        MIN(dif_date) AS dias_ultima_transacao,

        -- Engajamento últimos 30 dias x histórico do cliente
        ROUND(
            1.0 * COUNT(CASE WHEN dif_date <= 30 THEN IdTransacao END)
            / COUNT(IdTransacao),
        2) AS engajamento_D30xVida

    FROM tb_transacao
    GROUP BY IdCliente
),

-- ======================================================
-- CTE 3: Informações dos clientes (idade na base e pontos)
-- ======================================================
tb_clientes AS (
    SELECT 
        IdCliente, 
        qtdePontos, 

        -- Idade do cliente na base em dias
        julianday('2025-08-11') - julianday(substr(DtCriacao, 1, 10)) AS Idade_Base
    FROM clientes
),

-- ======================================================
-- CTE 4: Integra transações com produtos
-- ======================================================
tb_transacao_produto AS (
    SELECT 
        t1.*, 
        t3.DescNomeProduto
    FROM tb_transacao AS t1
    LEFT JOIN transacao_produto AS t2
        ON t1.IdTransacao = t2.IdTransacao
    LEFT JOIN produtos AS t3
        ON t2.IdProduto = t3.IdProduto
),

-- ======================================================
-- CTE 5: Uso de produtos por cliente
-- ======================================================
tb_cliente_produto AS (
    SELECT 
        IdCliente,
        DescNomeProduto,

        -- Uso total do produto
        COUNT(IdTransacao) AS Qtd_produto_vida,

        -- Janelas de tempo
        COUNT(CASE WHEN dif_date <= 60 THEN IdTransacao END) AS Qtd_produto_D60,
        COUNT(CASE WHEN dif_date <= 30 THEN IdTransacao END) AS Qtd_produto_D30,
        COUNT(CASE WHEN dif_date <= 15 THEN IdTransacao END) AS Qtd_produto_D15,
        COUNT(CASE WHEN dif_date <= 7  THEN IdTransacao END) AS Qtd_produto_D7

    FROM tb_transacao_produto
    GROUP BY IdCliente, DescNomeProduto
),

-- ======================================================
-- CTE 6: Ranking dos produtos mais utilizados por cliente
-- ======================================================
tb_rn_cliente_produto AS (
    SELECT 
        *,

        -- Ranking geral
        ROW_NUMBER() OVER (PARTITION BY IdCliente ORDER BY Qtd_produto_vida DESC) AS rn_vida,

        -- Rankings por janela
        ROW_NUMBER() OVER (PARTITION BY IdCliente ORDER BY Qtd_produto_D60 DESC) AS rn_60,
        ROW_NUMBER() OVER (PARTITION BY IdCliente ORDER BY Qtd_produto_D30 DESC) AS rn_30,
        ROW_NUMBER() OVER (PARTITION BY IdCliente ORDER BY Qtd_produto_D15 DESC) AS rn_15,
        ROW_NUMBER() OVER (PARTITION BY IdCliente ORDER BY Qtd_produto_D7 DESC)  AS rn_7
    FROM tb_cliente_produto
),

-- ======================================================
-- CTE 7: Análise por dia da semana (últimos 60 dias)
-- ======================================================
tb_cliente_dia AS (
    SELECT  
        IdCliente,

        CASE strftime('%w', dt_criacao)
            WHEN '0' THEN 'Domingo'
            WHEN '1' THEN 'Segunda-feira'
            WHEN '2' THEN 'Terça-feira'
            WHEN '3' THEN 'Quarta-feira'
            WHEN '4' THEN 'Quinta-feira'
            WHEN '5' THEN 'Sexta-feira'
            WHEN '6' THEN 'Sábado'
        END AS dia_semana,

        COUNT(IdTransacao) AS qtd_transacao

    FROM tb_transacao
    WHERE dif_date <= 60
    GROUP BY IdCliente, dia_semana
),

-- ======================================================
-- CTE 8: Ranking do dia da semana mais ativo
-- ======================================================
tb_cliente_dia_rn AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY IdCliente ORDER BY qtd_transacao DESC) AS rn_dia
    FROM tb_cliente_dia
),

-- ======================================================
-- CTE 9: Uso por período do dia (manhã/tarde/noite/madrugada)
-- ======================================================
tb_cliente_periodo_dia AS (
    SELECT 
        IdCliente,

        CASE 
            WHEN hora BETWEEN  7 AND 12 THEN 'MANHA'
            WHEN hora BETWEEN 13 AND 18 THEN 'TARDE'
            WHEN hora BETWEEN 19 AND 23 THEN 'NOITE'
            ELSE 'MADRUGADA'
        END AS periodo_dia,

        COUNT(IdTransacao) AS qtd_transacao

    FROM tb_transacao
    WHERE dif_date <= 60
    GROUP BY IdCliente, periodo_dia
),

-- ======================================================
-- CTE 10: Ranking do período do dia mais ativo
-- ======================================================
tb_cliente_periodo_dia_rn AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY IdCliente ORDER BY qtd_transacao DESC) AS rn_periodo_dia
    FROM tb_cliente_periodo_dia
)

-- ======================================================
-- RESULTADO FINAL: Tabela única consolidada de perfil comportamental
-- ======================================================
SELECT 
    t1.*,
    t2.Idade_Base,
    t2.qtdePontos,

    -- Produto mais utilizado por janela
    t3.DescNomeProduto AS produtovida,
    t4.DescNomeProduto AS produto60,
    t5.DescNomeProduto AS produto30,
    t6.DescNomeProduto AS produto15,
    t7.DescNomeProduto AS produto7,

    -- Dia e período mais ativos
    COALESCE(t8.dia_semana,  'SEM INFORMAÇÃO') AS dia_mais_ativo_60dias,
    COALESCE(t9.periodo_dia, 'SEM INFORMAÇÃO') AS periodo_dia_ativo_60dias

FROM tb_sumario_transacao AS t1

LEFT JOIN tb_clientes AS t2
    ON t1.IdCliente = t2.IdCliente

LEFT JOIN tb_rn_cliente_produto AS t3
    ON t1.IdCliente = t3.IdCliente AND t3.rn_vida = 1

LEFT JOIN tb_rn_cliente_produto AS t4
    ON t1.IdCliente = t4.IdCliente AND t4.rn_60 = 1

LEFT JOIN tb_rn_cliente_produto AS t5
    ON t1.IdCliente = t5.IdCliente AND t5.rn_30 = 1

LEFT JOIN tb_rn_cliente_produto AS t6
    ON t1.IdCliente = t6.IdCliente AND t6.rn_15 = 1

LEFT JOIN tb_rn_cliente_produto AS t7
    ON t1.IdCliente = t7.IdCliente AND t7.rn_7 = 1

LEFT JOIN tb_cliente_dia_rn AS t8
    ON t1.IdCliente = t8.IdCliente AND t8.rn_dia = 1

LEFT JOIN tb_cliente_periodo_dia_rn AS t9
    ON t1.IdCliente = t9.IdCliente AND t9.rn_periodo_dia = 1;
