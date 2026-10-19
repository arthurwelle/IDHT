# Banco Central, IPCA

Script: `R/03_pof.Rmd`
Não produz série: fornece o fator de atualização de preços da linha da POF.

## O que fica nesta pasta

Nada. A consulta é feita na API aberta do Banco Central a cada rodada.

## Série usada

IPCA, variação mensal, série 433 do Sistema Gerenciador de Séries Temporais
(SGS).

```
https://api.bcb.gov.br/dados/serie/bcdata.sgs.433/dados?formato=csv&dataInicial=01/01/2018&dataFinal=01/07/2024
```

O script acumula a variação entre a data de referência da POF e a base de preços
do deflator da PNADC em uso, e compara a linha recalculada com a que está em
`V_LINHA_POF_MENSAL`, em `R/00_config.R`. Diferença acima de 2% gera aviso.

## Sem internet

O script mantém o valor parametrizado e avisa. Nenhuma série deixa de ser gerada
por causa disso.

## Frequência de atualização

Mensal, mas só importa quando a safra do deflator da PNADC muda.
