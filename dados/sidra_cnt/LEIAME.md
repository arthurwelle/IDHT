# SIDRA e Contas Nacionais Trimestrais

Script: `R/05_sidra_cnt.Rmd`
Série produzida: `MassaRendaHabTodosTrab_noPIB`.

## O que fica nesta pasta

| Arquivo | Tipo | Conteúdo |
|---|---|---|
| `bruto/Tab_Compl_CNT.xlsx` | bruto | tabelas completas das Contas Nacionais Trimestrais, baixadas pelo script |

## Numerador, automático

Massa de rendimento mensal real habitual de todos os trabalhos, SIDRA, tabela
5606, variável 6293.

```r
sidrar::get_sidra(api = "/t/5606/n1/all/v/6293/p/all")
```

## Denominador, automático com cópia local

PIB a valores correntes das Contas Nacionais Trimestrais, do arquivo

```
https://ftp.ibge.gov.br/Contas_Nacionais/Contas_Nacionais_Trimestrais/Tabelas_Completas/Tab_Compl_CNT.zip
```

O script baixa, descompacta e grava a planilha em `bruto/`. Se o download
falhar, usa a cópia já gravada e avisa.

## Ponto de atenção no layout

A planilha muda de layout a cada divulgação: número de linhas de cabeçalho e
posição da coluna do PIB. O script não usa posição fixa: procura a aba de valores
correntes, localiza a linha de cabeçalho pela presença de "PIB" e identifica a
coluna pelo rótulo. Ainda assim, confira a aba e a coluna informadas na saída do
script a cada rodada.

## Leitura do indicador

Numerador e denominador vêm de metodologias distintas, pesquisa domiciliar e
contas nacionais. O nível da razão não deve ser lido como participação dos
salários na renda no sentido das contas nacionais. O que interessa é a variação
no tempo.

## Frequência de atualização

Trimestral, nas duas pontas.
