# ------------------------------------------------------------------------------
# config_local.R - caminhos desta maquina
#
# Copie este arquivo para R/config_local.R e ajuste os caminhos. O arquivo
# R/config_local.R NAO e versionado: cada maquina tem o seu.
#
# R/00_config.R carrega este arquivo, se existir, logo depois de definir os
# valores padrao. O que estiver aqui tem prioridade.
# ------------------------------------------------------------------------------

# Microdados da PNADC Trimestral, um arquivo por trimestre (PNADCT_<TTAAAA>.gz).
DIR_PNADCT <- "C:/caminho/para/PNADCT/GZ/"

# Microdados da PNADC Anual, por visita (<ano>.gz e <ano>_5v.gz).
DIR_PNADCA_V1 <- "C:/caminho/para/PNADCA/1_visita/"
DIR_PNADCA_V5 <- "C:/caminho/para/PNADCA/5_visita/"

# Microdados do Novo CAGED (CAGEDMOV<anomes>.7z), no layout do PDET
# (<ano>/<anomes>/). Deixe como esta se nao houver copia local: o script baixa
# do FTP ou usa as contagens da Base dos Dados.
DIR_CAGED_MICRO <- "C:/caminho/para/CAGED/DATA"

# Processos paralelos na leitura da PNADC. Cada um usa cerca de 2 GB.
# N_WORKERS <- 4

# Downloads de microdados.
# BAIXAR_PNADCT <- TRUE
# BAIXAR_PNADCA <- FALSE
# BAIXAR_CAGED  <- TRUE

# Reprocessar todos os trimestres da PNADC, ignorando o cache. Obrigatorio ao
# trocar deflator, linha da POF ou definicao de indicador.
# REFAZER_PNADCT <- FALSE
