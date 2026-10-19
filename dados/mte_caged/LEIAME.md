# CAGED, contratos atípicos

Script: `R/07_mte_caged.Rmd`
Série produzida: `Admitidos_ContratosAtipicos_MM`.

## O que fica nesta pasta

| Arquivo | Tipo | Conteúdo |
|---|---|---|
| `congelado/Admitidos_ContratosAtipicos_MM_ate2023.csv` | congelado | série harmonizada de 1T2012 a dezembro de 2023 |
| `bruto/NOVOCAGED_admitidos.csv` | bruto | total de admitidos, Novo CAGED, por ano e mês |
| `bruto/NOVOCAGED_admitidos_atipicos.csv` | bruto | admitidos em vínculos atípicos, Novo CAGED |
| `bruto/CAGED_antigo_admitidos.csv` | bruto | total de admitidos, CAGED antigo |
| `bruto/CAGED_antigo_admitidos_atipicos.csv` | bruto | admitidos atípicos, CAGED antigo |

## Por que parte é congelada

CAGED antigo (até 2019) e Novo CAGED (2020 em diante) têm metodologias
distintas. A emenda foi feita uma vez, por retropolação: a série antiga foi
trazida ao nível da nova, igualando o último patamar de uma ao primeiro da outra.
O fator usado foi 0,6726.

O degrau residual coincide com o início da pandemia, o que torna impossível
separar quebra metodológica de efeito real. Por isso o trecho até dezembro de
2023 é congelado e não se recalcula. De 2024 em diante, a série usa apenas o Novo
CAGED, que é homogêneo.

A data de corte está em `DATA_CONGELAMENTO`, em `R/00_config.R`.

## Definição de vínculo atípico

Conforme a nota técnica da RAIS: aprendizes, intermitentes, temporários,
contratos de até 30 horas semanais e contratados por empregador pessoa física
equiparada a jurídica, exceto construção civil (CNAE 41 a 43) no CAGED antigo.

## Como atualizar

Dois caminhos. O script tenta o primeiro e, sem dado, usa o segundo.

### Caminho 1, microdados do Novo CAGED

Arquivos `CAGEDMOV<anomes>.7z` do PDET, um por mes, cerca de 100 MB cada.

- Pasta local: `DIR_CAGED_MICRO`, em `R/00_config.R`, no layout do PDET
  (`<ano>/<anomes>/CAGEDMOV<anomes>.7z`).
- Sem arquivo local, o script baixa do FTP do MTE
  (`ftp.mtps.gov.br/pdet/microdados/NOVO CAGED/`), controlado por `BAIXAR_CAGED`.

O microdado bruto nao e guardado. O script descompacta em pasta temporaria, le
as colunas necessarias, conta e grava um resumo mensal em
`bruto/microdados/<anomes>.csv`, com admitidos, atipicos e desligamentos. Meses
ja resumidos nao sao reprocessados.

Colunas usadas e regra de vinculo atipico:

| Coluna | Uso |
|---|---|
| `saldomovimentacao` | 1 e admissao, -1 e desligamento |
| `categoria` | 103 aprendiz, 106 temporario (Lei 6.019), 111 intermitente |
| `indicadoraprendiz` | 1 e aprendiz |
| `indtrabintermitente` | 1 e intermitente |
| `indtrabparcial` | 1 e parcial |
| `horascontratuais` | menos de 30 horas semanais |
| `tipoestabelecimento` | 3 e CAEPF, pessoa fisica equiparada a juridica |

Os desligamentos desse mesmo resumo alimentam o indicador do TST e sao gravados
em `dados/tst/bruto/CAGED_desligamentos.csv`.

### Caminho 2, consultas na Base dos Dados

Alternativa quando nao ha acesso aos microdados. Rodar as duas consultas no
BigQuery e salvar os resultados em `bruto/`, com as colunas `ano`, `mes` e `N`.

Admitidos em vínculos atípicos:

```sql
SELECT ano, mes, COUNT(*) AS N
FROM `basedosdados.br_me_caged.microdados_movimentacao`
WHERE saldo_movimentacao = 1
  AND (horas_contratuais < 30
       OR indicador_aprendiz = '01'
       OR indicador_trabalho_parcial = '01'
       OR indicador_trabalho_intermitente = '01'
       OR tipo_estabelecimento = '03')
GROUP BY ano, mes
```

Total de admitidos: a mesma consulta, sem o bloco `AND (...)`.

Para rodar do R, com projeto do BigQuery configurado:
`basedosdados::read_sql(query)`.

Consultas equivalentes no CAGED antigo, usadas apenas para reconstruir o trecho
congelado: tabela `microdados_antigos`, filtro `admitidos_desligados = '01'`,
jornada em `quantidade_horas_contratadas`, e exclusão da construção civil no
critério de tipo de estabelecimento.

## Verificação da emenda

O script compara o último ponto congelado com o primeiro ponto novo e avisa se o
degrau passar de 2 pontos percentuais. Degrau grande indica que as contagens
novas não estão no mesmo nível do congelado.

## Frequência de atualização

Mensal, com defasagem de cerca de 45 dias.
