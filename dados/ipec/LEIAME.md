# IPEC, confiança nos sindicatos

Script: `R/10_ipec.Rmd`
Série produzida: `ConfiancaSindicatos`.

## O que fica nesta pasta

| Arquivo | Tipo | Conteúdo |
|---|---|---|
| `manual/Confianca_Sindicato_ICS.xlsx` | manual | item sindicatos do ICS, uma linha por ano |

## Fonte

Índice de Confiança Social (ICS), do IPEC, sucessor do Ibope Inteligência.
Pesquisa anual de opinião, população de 16 anos ou mais. Na edição usada: 2.000
entrevistas em 127 municípios, intervalo de confiança de 95% e margem de erro de
2 pontos percentuais.

Site: <https://www.ipec-inteligencia.com.br/>

## Por que é coleta manual

Não há base aberta nem API. O resultado sai em relatório anual em PDF, e o
projeto usa apenas o item sindicatos. O número é lido no relatório e digitado na
planilha.

## Como atualizar

1. Localizar o relatório do ICS do ano no site do IPEC.
2. Encontrar a tabela de confiança por instituição e anotar o valor do item
   sindicatos.
3. Acrescentar uma linha na planilha, com ano e valor.

Layout esperado:

| Ano | Valor |
|---|---|
| 2023 | 48 |

O valor pode estar em percentual de 0 a 100 ou em proporção: o script normaliza.

## Harmonização

Série anual interpolada para trimestral. Três de cada quatro pontos são
construídos.

## Leitura do indicador

É o único indicador de percepção do feixe, com amostra pequena, margem de erro da
mesma ordem da variação anual e dependência de uma publicação privada, sem
compromisso de continuidade. Não entra no IDH-T.

## Frequência de atualização

Anual, quando o IPEC publica o relatório.
