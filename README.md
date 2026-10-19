# Projeto Índice do Trabalho Decente (ITD), pacote de reprodução

Este diretório reconstrói, do zero, o feixe de indicadores do trabalho decente e
o índice sintético IDH-T. Cobre a busca dos dados, a limpeza, a harmonização, o
cálculo e a validação de cada série.

- **Documentação metodológica**: `ITD_fontes_metodologia.pdf`, fonte em `.Rmd`.
  Descreve os 21 indicadores (variáveis, fórmulas, quebras de série) e o cálculo
  do índice.
- **Código**: pasta `R/`, um documento por fonte de dados.
- **Dados**: pasta `dados/`, uma subpasta por fonte, com LEIAME próprio.
- **Saídas**: pasta `output/`, uma série por arquivo, mais o índice.

Autor: Arthur Welle (arthurwelle@gmail.com). CESIT, Instituto de Economia,
Unicamp.

## Estrutura

```
SmartLab/
  README.md
  ITD_fontes_metodologia.Rmd / .pdf
  IMG_doc/                     figuras da Secao 1 da documentacao, uma por indicador
  R/
    00_config.R                caminhos, parametros, dicionario das series, funcoes
    01_pnadc_trimestral.Rmd    14 series, 7 delas no indice
    02_pnadc_anual.Rmd         cobertura previdenciaria 65+
    03_pof.Rmd                 linha de renda necessaria
    04_ipeadata.Rmd            salario minimo real
    05_sidra_cnt.Rmd           massa de rendimentos sobre o PIB
    06_dieese.Rmd              greves e acordos, 2 series do indice
    07_mte_caged.Rmd           contratos atipicos
    08_tst.Rmd                 processos trabalhistas
    09_inss.Rmd                acidentes de trabalho
    10_ipec.Rmd                confianca nos sindicatos
    11_dieese_greves_pdf.Rmd   le os balancos de greves nos PDF do DIEESE
    12_dieese_reajustes_pdf.Rmd le os boletins de negociacao nos PDF do DIEESE
    20_idht.Rmd                painel e indice final
  run_all.Rmd                  executa tudo e gera o relatorio da rodada
  dados/
    MANIFESTO.csv              arquivos usados, data e soma de verificacao
    <fonte>/LEIAME.md          origem, formato, atualizacao, o que e congelado
    <fonte>/bruto|manual|congelado/
  output/
    series/                    uma serie por arquivo
    painel_indicadores.csv     todas as series empilhadas
    idht.csv                   indice final
    idht_componentes.csv       series normalizadas que compoem o indice
    IMG/                       graficos, refeitos a cada rodada
    cache_pnadct/              um .rds por trimestre processado
```

## Requisitos

R 4.4 ou superior.

```r
install.packages(c("data.table", "dplyr", "tidyr", "stringr", "lubridate",
                   "readxl", "zoo", "ggplot2", "knitr", "rmarkdown",
                   "future.apply", "R.utils", "Hmisc", "reldist",
                   "sidrar", "ipeadatar", "PNADcIBGE"))
```

Memória: a PNADC é lida trimestre a trimestre, com seleção de colunas. O pico
fica em torno de 2 GB por processo, e o padrão são 4 processos em paralelo.

## Como rodar

Da raiz deste diretório:

```r
rmarkdown::render("run_all.Rmd")
```

O resultado é `run_all.html`, o relatório da rodada: o que foi baixado, o que
veio de arquivo congelado, o resultado das validações e o índice final.

Para rodar uma fonte isolada:

```r
source("R/00_config.R")
rmarkdown::render("R/01_pnadc_trimestral.Rmd")
```

Antes da primeira execução, ajuste os caminhos no topo de `R/00_config.R`.

## Como cada fonte é obtida

| Fonte | Obtenção | Séries | Observação |
|---|---|---|---|
| PNADC Trimestral | microdados locais mais `PNADcIBGE` para trimestres novos | 14 | microdados ficam fora do pacote |
| PNADC Anual | microdados locais mais `PNADcIBGE` | 1 | primeira visita, quinta em 2020 e 2021 |
| POF 2017-2018 | tabulação congelada | parâmetro | muda só com POF nova |
| IPEADATA | API, `ipeadatar` | 1 | automático |
| SIDRA | API, `sidrar` | 1 (numerador) | automático |
| Contas Nacionais | download do FTP do IBGE | 1 (denominador) | layout muda, script confere |
| Banco Central | API SGS, série 433 | parâmetro | atualiza a linha da POF |
| DIEESE | leitura automática dos PDF, com planilha manual como alternativa | 2 | scripts 11 e 12 |
| CAGED | consulta SQL mais trecho congelado | 1 | emenda CAGED antigo e Novo CAGED |
| TST | Base de Dados JT mais trecho congelado | 1 | mensal só a partir de 2018 |
| INSS | consulta AEAT, manual | 1 | base aberta de 2018 em diante como alternativa |
| IPEC | relatório anual em PDF, manual | 1 | sem base aberta |

## Séries congeladas

Três séries têm trecho histórico que não se recalcula, porque a harmonização foi
feita uma vez e não é reproduzível a partir da fonte primária. O corte está em
`DATA_CONGELAMENTO`, em `R/00_config.R`, hoje dezembro de 2023.

| Série | O que foi congelado | O que entra em produção |
|---|---|---|
| `Admitidos_ContratosAtipicos_MM` | CAGED antigo retropolado e emendado ao Novo CAGED | Novo CAGED, de 2024 em diante |
| `NovasAcoes_sobre_Demitidos_MM` | mensalização dos totais anuais do TST anteriores a 2018 | TST mensal, de 2024 em diante |
| `TxOcupadosRendaAbaixoPOF` | tabulação da POF que define a linha de renda | nada, muda só com POF nova |

Nos dois primeiros casos o script compara o último ponto congelado com o primeiro
ponto novo e avisa se houver degrau acima de 2 pontos percentuais.

## As nove séries do IDH-T

| Série | Script | Polaridade |
|---|---|---|
| `TxCompostaSubutilizacao` | 01 | negativa |
| `PrevidenciaTodosTrab` | 01 | positiva |
| `CarteiraTrabAssalariados` | 01 | positiva |
| `EstabilidadeEmpregoPrivado` | 01 | positiva |
| `TxOcupadosRendaAbaixoPOF` | 01, linha vinda de 03 | negativa |
| `RendimentoRealMedio` | 01 | positiva |
| `TxJornadaAcima44h` | 01 | negativa |
| `GrevesPropositivas` | 06 | positiva |
| `ReajustesAcimaINPC_MM` | 06 | positiva |

As demais séries do feixe entram no painel de acompanhamento, não no índice.

## Validação

Cada script valida a própria série antes de gravar: ausência de valores vazios e
de datas repetidas, valores dentro de faixa plausível, grade de datas sem buraco
e salto máximo entre pontos vizinhos. Faixa e salto são definidos por série.

Problema que impede o uso da série para a execução. Problema que merece
conferência gera aviso e segue. Os dois aparecem no relatório da rodada.

## Atualização periódica

1. Baixar o novo trimestre da PNADC e, se houver, o novo arquivo de deflatores.
2. Se o deflator mudou de base, atualizar a linha da POF (`R/03_pof.Rmd` e
   `V_LINHA_POF_MENSAL`), apagar `output/cache_pnadct/` e rodar com
   `REFAZER_PNADCT <- TRUE`.
3. Pedir ao DIEESE a atualização das duas séries de diálogo social.
4. Atualizar as consultas do CAGED e a Base de Dados JT do TST.
5. Rodar `run_all.Rmd` e conferir o relatório.

## Decisões de produção

Dois pontos antes em aberto estão fixados no código e documentados:

1. **Janela de normalização**: recalculada a cada rodada, sobre todo o período
   disponível. O índice é por isso uma série revisável: trimestres novos podem
   redefinir mínimo e máximo e alterar valores passados. Seção 2, Passo 3 da
   documentação metodológica.
2. **Séries anuais**: o valor do ano é repetido nos seus quatro trimestres
   (`TRATAMENTO_ANUAL <- "repetir"`, em `R/00_config.R`). A alternativa,
   interpolar, foi testada e descartada: correlação de 0,995 entre as duas
   curvas e três trimestres de atraso no fim da série. Seção 1, série
   `GrevesPropositivas`.

O último trimestre publicável é o da fonte mais defasada, hoje o balanço anual de
greves do DIEESE, divulgado no ano seguinte ao de referência.

Fica em aberto a política de versionamento das séries e do índice: como nomear e
guardar cada rodada, de modo que um resultado publicado possa ser recuperado
depois de uma revisão.
