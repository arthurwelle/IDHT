# TST, novos processos trabalhistas

Script: `R/08_tst.Rmd`
Série produzida: `NovasAcoes_sobre_Demitidos_MM`.

## O que fica nesta pasta

| Arquivo | Tipo | Conteúdo |
|---|---|---|
| `congelado/NovasAcoes_sobre_Demitidos_MM_ate2023.csv` | congelado | série harmonizada de janeiro de 2012 a dezembro de 2023 |
| `bruto/Base_de_Dados_JT.csv` | bruto | Base de Dados JT do TST, recebidos e julgados |
| `bruto/CAGED_desligamentos.csv` | bruto | desligamentos por ano e mês, denominador |

## Fonte do numerador

Base de Dados JT, publicada em
<https://www.tst.jus.br/web/estatistica/jt/recebidos-e-julgados>. Traz casos
recebidos e julgados por instância, ano, mês, região e assunto. Dados mensais a
partir de 2018; antes disso, apenas totais anuais.

O script filtra `Variavel` igual a Recebidos e instância das Varas do Trabalho, e
soma `Quantidade` por ano e mês.

Para automatizar o download, preencher `URL_BASE_JT` no script com o endereço do
arquivo na página do TST. O endereço muda a cada republicação, por isso o padrão
é usar a cópia em `bruto/` e conferir a página antes de cada atualização.

## Fonte do denominador

Desligamentos do CAGED, mesma base do script 07:

```sql
SELECT ano, mes, COUNT(*) AS N
FROM `basedosdados.br_me_caged.microdados_movimentacao`
WHERE saldo_movimentacao = -1
GROUP BY ano, mes
```

Esse arquivo e gravado automaticamente por `R/07_mte_caged.Rmd` quando os
microdados do CAGED estao disponiveis. Sem eles, rodar a consulta e salvar o
resultado em `bruto/CAGED_desligamentos.csv`, com as colunas `ano`,
`mes` e `N`.

## Por que parte é congelada

Antes de 2018 o TST publica apenas totais anuais. A mensalização desse trecho foi
feita uma vez: aplicou-se o padrão sazonal obtido de fontes secundárias e
ajustou-se o nível por um fator de compatibilização, calculado sobre o período em
que as duas séries coexistem, de 2014 a 2018.

Esse procedimento não é reproduzível a partir de fonte primária, e por isso o
trecho até dezembro de 2023 é congelado. De 2024 em diante, a série usa apenas os
dados mensais oficiais do TST.

## Verificação da emenda

O script compara o último ponto congelado com o primeiro ponto novo e avisa se o
degrau passar de 2 pontos percentuais, o que costuma indicar filtro diferente na
Base de Dados JT.

## Frequência de atualização

Mensal no TST, mensal no CAGED.
