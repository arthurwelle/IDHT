# INSS, acidentes de trabalho

Script: `R/09_inss.Rmd`
Série produzida: `AcidentesTrabalho_ponderadoSegurada`.

## O que fica nesta pasta

| Arquivo | Tipo | Conteúdo |
|---|---|---|
| `manual/AcidentesTrabalhoINSS1999_2022.csv` | manual | CAT registradas por ano e mês, exportado do AEAT |

## Fonte do numerador

AEAT, Anuário Estatístico de Acidentes do Trabalho, consultado em
<https://www3.dataprev.gov.br/aeat/inicio.htm>, tabela de acidentes por mês
(`AEAT/gliq/liq02/liq02.PHP`).

A consulta é por formulário: escolher a tabela de acidentes do trabalho
registrados por mês, o período desejado e exportar em CSV. O arquivo sai em
latin1, com uma linha de cabeçalho antes dos nomes das colunas, meses por
extenso, ano preenchido apenas na primeira linha de cada bloco, linhas de total
por ano e uma coluna por motivo: típico, trajeto, doença do trabalho e sem CAT.

O script lê o arquivo nesse formato, descarta as linhas de total, preenche o ano
para baixo e calcula o numerador como o total menos a coluna sem CAT, de modo a
contar apenas as CAT efetivamente registradas.

## Alternativa automatizável

Há base aberta de CAT em dados.gov.br, mensal, de 2018 em diante:
<https://dados.gov.br/dados/conjuntos-dados/comunicacoes-de-acidente-de-trabalho-cat>.

Ela não cobre o início da série, por isso a consulta do AEAT segue como fonte
oficial do indicador. Se o SmartLab quiser automatizar, o caminho é usar a base
aberta de 2018 em diante e congelar o trecho anterior, como foi feito com CAGED e
TST.

## Fonte do denominador

População segurada, calculada na PNADC Trimestral pelo script 01, série
`PopulacaoSeguradaINSS`: assalariados formais do setor privado, exceto
domésticos (`VD4009 == 1`), mais empregadores e conta-própria que contribuem para
a previdência (`VD4009` em 8 ou 9, com `VD4012 == 1`).

É o contingente coberto pelo seguro de acidentes do trabalho, o que torna a razão
comparável ao universo das CAT.

## Harmonização

Numerador e denominador entram em média móvel de 12 meses. A população segurada é
trimestral e é interpolada para mensal antes da média. O indicador é expresso em
acidentes por mil segurados.

## Leitura do indicador

Mede registro, não ocorrência. A CAT é emitida pela empresa, que tem incentivo a
não emitir; doenças relacionadas ao trabalho dependem de diagnóstico;
trabalhadores informais estão fora do sistema; e aumento de fiscalização eleva o
número de registros sem que a incidência real tenha subido.

## Frequência de atualização

Mensal no AEAT, com defasagem de alguns meses.
