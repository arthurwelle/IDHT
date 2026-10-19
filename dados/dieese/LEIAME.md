# DIEESE, greves e acordos coletivos

Script: `R/06_dieese.Rmd`
Séries produzidas: `GrevesPropositivas` e `ReajustesAcimaINPC_MM`. As duas entram
no IDH-T.

## O que fica nesta pasta

| Arquivo | Tipo | Conteúdo |
|---|---|---|
| `manual/DIEESE_GrevesPropositivasDefensivas.xlsx` | manual | greves por caráter, anual |
| `manual/DIEESE_ReajustesAcimaINPC.xlsx` | manual | reajustes acima do INPC, abas `anual` e `mensal` |
| `manual/mediador_reajustes_por_regiao.xlsx` | manual, fora do repositorio | reajustes por regiao e data-base; fornecido pelo DIEESE sob demanda, ver fim deste arquivo |

## Por que é coleta manual

Nenhuma das duas séries tem base aberta no detalhe necessário. São tabulações
especiais fornecidas pelo DIEESE a pedido. Os balanços públicos do DIEESE trazem
os números agregados, mas não a série contínua com a classificação usada aqui.

## Como pedir a atualização

Pedido ao DIEESE, com estas especificações:

**Greves, Sistema de Acompanhamento de Greves (SAG).** Número de greves por ano,
separado por caráter, propositivas e defensivas, para o Brasil, de 2012 em
diante. São propositivas as greves por novas conquistas ou avanço sobre normas já
estabelecidas, e defensivas as que buscam manutenção ou cumprimento de direitos.

**Reajustes, Sistema de Acompanhamento de Contratações Coletivas (SACC).**
Proporção dos instrumentos coletivos com reajuste acima do INPC, Brasil, mensal
de 2018 em diante e anual antes disso. Considerar apenas reajustes aplicados aos
salários acima do piso; em reajuste escalonado, registrar o percentual da menor
faixa; reajuste parcelado entra pelo percentual total.

## Layout esperado

`DIEESE_GrevesPropositivasDefensivas.xlsx`, aba única:

| Ano | Propositivas | Defensivas |
|---|---|---|
| 2012 | 566 | 592 |

`DIEESE_ReajustesAcimaINPC.xlsx`, aba `anual`:

| Ano | AcimaINPC |
|---|---|
| 2012 | 0,936 |

Aba `mensal`, de 2018 em diante:

| data | acima do inpc |
|---|---|
| 2018-01 | 68,0 |

A data vem como ano e mês. O valor pode vir em proporção ou em percentual de 0 a
100: o script normaliza.

## Extensao da serie de reajustes

Este arquivo nao esta neste repositorio. E uma tabulacao do Mediador fornecida
pelo DIEESE para uso no projeto, e nao e redistribuida; esta listada no
`.gitignore`. Para obte-la, pedir ao DIEESE. Sem ela o script segue funcionando:
os reajustes vem dos boletins em PDF, lidos por `R/12_dieese_reajustes_pdf.Rmd`,
que tem prioridade sobre esta tabulacao.

O arquivo `mediador_reajustes_por_regiao.xlsx` traz a distribuicao dos reajustes
em relacao ao INPC por regiao geografica e data-base, mensal, e costuma estar
mais atualizado que a aba mensal da outra planilha.

O valor nacional e a media das regioes ponderada pelo numero de reajustes. Essa
agregacao reproduz a serie nacional do DIEESE: correlacao de 0,998 no periodo em
que as duas existem, com diferenca na casa decimal.

O script usa a aba mensal como fonte principal e o Mediador apenas para os meses
posteriores ao ultimo disponivel nela.

Layout esperado, aba `reajustes_regiao`, a partir da terceira linha: `regiao`,
`db_ano_mes` (AAAA-MM), `abaixo (%)`, `igual (%)`, `acima (%)` e `n de reajustes`.

## Harmonização

- Greves: série anual interpolada para trimestral. Três de cada quatro pontos são
  construídos.
- Reajustes: a parte anual é interpolada para mensal, emendada à parte mensal e
  suavizada por média móvel de 12 meses.

## Ponto de atenção

O SAG depende de cobertura da imprensa, o que pode afetar a comparabilidade ao
longo do tempo. As duas séries são as únicas do índice que não vêm de pesquisa
amostral ou registro administrativo, e juntas respondem por boa parte do peso do
IDH-T.

## Frequência de atualização

Greves: anual. Reajustes: mensal, com defasagem de alguns meses.
