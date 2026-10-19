# IPEADATA, salário mínimo real

Script: `R/04_ipeadata.Rmd`
Série produzida: `SalarioMinimoReal_MM`.

## O que fica nesta pasta

Nada. A fonte é totalmente automatizada: o script consulta a API do IPEA a cada
rodada, pelo pacote `ipeadatar`.

## Série usada

`GAC12_SALMINRE12`: salário mínimo nominal deflacionado pelo INPC, mensal, em
reais constantes do último mês da série.

```r
ipeadatar::ipeadata("GAC12_SALMINRE12")
```

Para procurar outras séries: `ipeadatar::available_series()`.

## Harmonização

O salário mínimo é reajustado uma vez por ano, o que produz degraus na série
mensal. A versão que entra no painel é a média móvel de 12 meses.

## Ponto de atenção

A base de preços muda a cada atualização do IPEA, que traz os valores para o mês
mais recente. Isso não afeta o índice, porque a normalização de mínimo e máximo é
invariante a mudanças de escala, mas afeta a comparação de valores absolutos
entre rodadas. Sem internet, a série não é gerada e o script para com erro
explicando a causa.

## Frequência de atualização

Mensal.
