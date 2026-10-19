# PNAD Contínua Anual

Script: `R/02_pnadc_anual.Rmd`
Série produzida: `PropoRendaAposentadoriaAcima65anos`.

## O que fica nesta pasta

Nada. Os microdados anuais ficam fora do pacote, apontados por `DIR_PNADCA_V1` e
`DIR_PNADCA_V5` em `R/00_config.R`, pela mesma razão da trimestral: tamanho.

## Como o script obtém os microdados

1. **Anos já processados**: arquivos `<ano>.gz` nas pastas de primeira e quinta
   visita.
2. **Anos novos**: pacote `PNADcIBGE`, com
   `get_pnadc(year = ano, interview = 1, design = FALSE)`. O download não é
   gravado.

## Qual visita usar

- **Primeira visita** em todos os anos disponíveis.
- **Quinta visita** em 2020 e 2021. A primeira visita desses dois anos foi a
  campo por telefone e os microdados não foram divulgados.

## Variáveis

| Código | Conteúdo |
|---|---|
| `V1032` | peso amostral da visita anual |
| `V2009` | idade |
| `V50011` | recebeu aposentadoria de instituto de previdência |
| `V50021` | recebeu pensão de instituto de previdência |

Os códigos das variáveis de rendimento mudaram ao longo da série. Antes de
incluir um ano novo, confira o dicionário daquele ano. O script avisa quando as
variáveis esperadas não estão presentes e segue sem o ano.

## Como recriar a pasta de microdados do zero

```r
library(PNADcIBGE)
library(data.table)

vars <- c("V1032", "V2009", "V50011", "V50021")

for (ano in 2012:2024) {
  visita <- if (ano %in% c(2020, 2021)) 5 else 1
  d <- try(get_pnadc(year = ano, interview = visita, vars = vars,
                     design = FALSE, labels = FALSE, savedir = tempdir()))
  if (inherits(d, "try-error")) next
  destino <- if (visita == 1) "C:/caminho/1_visita" else "C:/caminho/5_visita"
  fwrite(as.data.table(d), file.path(destino, paste0(ano, ".gz")))
}
```

## Harmonização

A série é anual e o painel é trimestral. Os trimestres intermediários são
preenchidos por interpolação linear: três de cada quatro pontos são construídos.

## Frequência de atualização

Anual, com defasagem de cerca de um ano em relação ao ano de referência.
