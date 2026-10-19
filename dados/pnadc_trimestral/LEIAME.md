# PNAD Contínua Trimestral

Script: `R/01_pnadc_trimestral.Rmd`
Séries produzidas: 14, entre elas 7 das 9 do IDH-T.

## O que fica nesta pasta

| Arquivo | Tipo | Conteúdo |
|---|---|---|
| `deflator_PNADC.xls` | bruto | fatores Habitual e Efetivo por ano, trimestre e UF |

Os microdados **não ficam aqui**. Cada trimestre tem cerca de 200 MB e a série
completa passa de 10 GB. Eles vivem em uma pasta fora do pacote, apontada por
`DIR_PNADCT` em `R/00_config.R`.

## Como o script obtém os microdados

1. **Trimestres já processados**: arquivos `PNADCT_<TTAAAA>.gz` em `DIR_PNADCT`.
   São microdados lidos com o dicionário SAS do IBGE e gravados em formato
   compacto. É o caminho usado para toda a série histórica.
2. **Trimestres novos**: o script busca pelo pacote `PNADcIBGE`, que baixa do FTP
   do IBGE, lê e devolve o microdado em memória. O download não é gravado, por
   decisão de projeto: evita duplicar dezenas de gigabytes dentro do pacote.

## Como recriar a pasta de microdados do zero

Só é necessário se a pasta apontada por `DIR_PNADCT` for perdida. Duas opções.

**Opção 1, pelo pacote PNADcIBGE, um trimestre por vez:**

```r
library(PNADcIBGE)
library(data.table)

dir_destino <- "C:/caminho/para/GZ"
vars <- c("V1028", "V2007", "V2010", "V4006", "V4006A", "V4010", "V4019",
          "V40401", "V40402", "V40403", "VD4001", "VD4002", "VD4003",
          "VD4004", "VD4004A", "VD4005", "VD4009", "VD4011", "VD4012",
          "VD4019", "VD4031")

for (ano in 2012:2025) {
  for (tri in 1:4) {
    d <- try(get_pnadc(year = ano, quarter = tri, vars = vars,
                       design = FALSE, labels = FALSE, savedir = tempdir()))
    if (inherits(d, "try-error")) next
    fwrite(as.data.table(d),
           file.path(dir_destino, sprintf("PNADCT_%02d%d.gz", tri, ano)))
  }
}
```

**Opção 2, direto do FTP:** baixar os `.txt` em
`ftp.ibge.gov.br/Trabalho_e_Rendimento/Pesquisa_Nacional_por_Amostra_de_Domicilios_continua/Trimestral/Microdados/`
mais o dicionário em `Documentacao/`, ler com o input SAS e gravar em `.gz`.

## Deflatores

Baixar `Deflatores.zip` em
`.../Trimestral/Microdados/Documentacao/Deflatores.zip`, descompactar e salvar o
`.xls` nesta pasta como `deflator_PNADC.xls`.

A safra do deflator define a base de preços de toda a série de rendimentos e o
último trimestre calculável. Trimestres de microdado sem cobertura do deflator
são ignorados, com aviso.

**Ao trocar a safra do deflator:**

1. substituir o arquivo nesta pasta;
2. atualizar a linha da POF (`R/03_pof.Rmd` e `V_LINHA_POF_MENSAL` em
   `R/00_config.R`);
3. rodar com `REFAZER_PNADCT <- TRUE`, porque todos os valores de rendimento
   mudam.

## Frequência de atualização

Trimestral. O IBGE divulga cerca de dois meses após o fim do trimestre de
referência. O arquivo de deflatores costuma sair junto.
