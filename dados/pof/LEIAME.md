# POF 2017-2018, linha de renda necessária

Script: `R/03_pof.Rmd`
Produz um parâmetro, não uma série: a linha usada pelo indicador
`TxOcupadosRendaAbaixoPOF`, calculado na PNADC Trimestral.

## O que fica nesta pasta

| Arquivo | Tipo | Conteúdo |
|---|---|---|
| `congelado/POF_RendaNecessaria_RendaEfetiva_Vintesimos.csv` | congelado | renda efetiva e renda necessária declarada, por centésimo de renda domiciliar per capita |

## Por que é congelado

A tabulação foi feita uma vez sobre os microdados da POF 2017-2018 e só muda
quando sai uma POF nova, o que acontece cerca de uma vez por década. Recalcular a
cada rodada exigiria processar os microdados da POF sem nenhum ganho.

O script lê o arquivo congelado, reencontra o ponto de cruzamento das duas curvas
e compara com o valor em uso, como conferência.

## Como a linha foi construída

1. Na POF, cada domicílio declara a renda que considera necessária para viver.
2. Por centésimo de renda domiciliar per capita, comparam-se renda necessária
   declarada e renda efetiva.
3. A linha é o ponto em que as curvas se cruzam: **R$ 885,00** a preços da POF.
4. O valor é atualizado pelo IPCA para a base de preços do deflator da PNADC em
   uso: **R$ 1.248,11** a preços de julho de 2024.
5. A linha mensal é convertida em renda por hora, dividida pela jornada de
   referência de 44 horas.

## Atualização de preços

O fator do IPCA é obtido na API aberta do Banco Central, série 433 do SGS. Sem
internet, o script mantém o valor parametrizado em `R/00_config.R` e avisa.

Ao trocar a safra do deflator da PNADC:

1. ajustar `DATA_BASE_LINHA` em `R/03_pof.Rmd`;
2. rodar o script e copiar a linha recalculada para `V_LINHA_POF_MENSAL` em
   `R/00_config.R`;
3. rodar a PNADC Trimestral com `REFAZER_PNADCT <- TRUE`.

## Como recriar a tabulação do zero

Necessário apenas quando sair uma POF nova. Nos microdados da POF, calcular por
centésimo de renda domiciliar per capita a média da renda efetiva e a média da
renda declarada como necessária, e gravar no mesmo formato longo do arquivo
congelado, com as colunas `Centesimos`, `variable` (Effective ou Necessary) e
`value`.

## Frequência de atualização

Decenal, na divulgação de uma nova POF.
