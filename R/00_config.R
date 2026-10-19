# ------------------------------------------------------------------------------
# Projeto Indice do Trabalho Decente (ITD)
# 00_config.R - caminhos, parametros e funcoes comuns
#
# Rode este script antes de qualquer outro. Ele nao produz series: define onde
# estao os dados, os parametros do feixe, o dicionario das series e as funcoes
# usadas pelos scripts de cada fonte.
#
# Autor: Arthur Welle - arthurwelle@gmail.com
# ------------------------------------------------------------------------------

suppressPackageStartupMessages({
  library(data.table)
  library(dplyr)
  library(stringr)
  library(zoo)
  library(ggplot2)
})

# ------------------------------------------------------------------------------
# 1. Caminhos
#    Os caminhos de microdados abaixo sao exemplos. O valor desta maquina vai
#    em R/config_local.R, que nao e versionado. Veja R/config_local_exemplo.R.
# ------------------------------------------------------------------------------

# Raiz do pacote (pasta que contem o README.md).
DIR_RAIZ <- normalizePath(".", winslash = "/")

DIR_DADOS <- file.path(DIR_RAIZ, "dados")
DIR_OUT   <- file.path(DIR_RAIZ, "output")
DIR_SERIES <- file.path(DIR_OUT, "series")
DIR_IMG    <- file.path(DIR_OUT, "IMG")
DIR_CACHE  <- file.path(DIR_OUT, "cache_pnadct")

# Uma pasta por fonte, dentro de dados/. Cada uma tem seu LEIAME.md.
DIR_FONTE <- function(fonte) file.path(DIR_DADOS, fonte)

for (p in c(DIR_DADOS, DIR_OUT, DIR_SERIES, DIR_IMG, DIR_CACHE)) {
  dir.create(p, showWarnings = FALSE, recursive = TRUE)
}

# Microdados da PNADC Trimestral ja processados, um arquivo por trimestre
# (PNADCT_<TTAAAA>.gz). Esta pasta fica FORA do pacote por causa do tamanho
# (cerca de 200 MB por trimestre). Trimestres que nao estiverem aqui sao
# buscados pelo pacote PNADcIBGE, sem gravar o download.
# Veja dados/pnadc_trimestral/LEIAME.md.
DIR_PNADCT <- "C:/caminho/para/PNADCT/GZ/"

# Microdados da PNADC Anual, por visita. Mesma logica: ficam fora do pacote.
DIR_PNADCA_V1 <- "C:/caminho/para/PNADCA/1_visita/"
DIR_PNADCA_V5 <- "C:/caminho/para/PNADCA/5_visita/"

# Deflatores da PNADC (Deflatores.zip do FTP do IBGE, ja descompactado).
# Deflatores da PNADC. O arquivo e baixado do FTP do IBGE por
# f_baixa_deflator() e gravado com o nome de origem, que traz a base de
# precos (deflator_PNADC_<ano>_trimestral_<meses>.xls). Usa-se sempre o mais
# recente presente na pasta.
URL_DEFLATOR <- paste0("https://ftp.ibge.gov.br/Trabalho_e_Rendimento/",
                       "Pesquisa_Nacional_por_Amostra_de_Domicilios_continua/",
                       "Trimestral/Microdados/Documentacao/Deflatores.zip")

# ------------------------------------------------------------------------------
# 2. Parametros do feixe
# ------------------------------------------------------------------------------

# Primeiro ano da serie. A PNADC Trimestral comeca no 1T2012.
ANO_INICIO <- 2012

# Jornada semanal acima da qual ha excesso (limite constitucional).
V_JORNADA_MAX <- 44

# Linha de renda necessaria da POF 2017-2018, mensal, na base de precos do
# deflator da PNADC em uso. Ao trocar a safra do deflator, atualize este valor
# (veja R/03_pof.Rmd) e rode de novo com REFAZER_PNADCT <- TRUE.
V_LINHA_POF_MENSAL <- 1248.11
V_LINHA_POF_HORA   <- V_LINHA_POF_MENSAL / V_JORNADA_MAX

# Fim do periodo congelado. Series com emenda historica (CAGED, TST, POF) usam
# arquivo congelado ate esta data e so calculam dali para frente.
# Veja dados/<fonte>/LEIAME.md.
DATA_CONGELAMENTO <- as.IDate("2023-12-01")

# Processos paralelos na leitura da PNADC. Cada um usa cerca de 2 GB.
N_WORKERS <- 4

# TRUE reprocessa todos os trimestres da PNADC, ignorando o cache.
# Obrigatorio ao trocar deflator, linha da POF ou definicao de indicador.
REFAZER_PNADCT <- FALSE

# ------------------------------------------------------------------------------
# 3. Dicionario das series
#    Nome interno, rotulo, dimensao, polaridade e se entra no indice final.
#    E a referencia usada por R/20_idht.Rmd.
# ------------------------------------------------------------------------------

DIC_SERIES <- data.table::fread(text = '
variavel|rotulo|dimensao|polaridade|no_idht|fonte
TxCompostaSubutilizacao|Taxa composta de subutilizacao|ocupacao_suficiente|negativa|TRUE|pnadc_trimestral
PrevidenciaTodosTrab|Contribuicao a previdencia|acesso_a_direitos|positiva|TRUE|pnadc_trimestral
CarteiraTrabAssalariados|Carteira entre os assalariados|acesso_a_direitos|positiva|TRUE|pnadc_trimestral
EstabilidadeEmpregoPrivado|Estabilidade no emprego formal privado|acesso_a_direitos|positiva|TRUE|pnadc_trimestral
NovasAcoes_sobre_Demitidos_MM|Novos processos sobre desligamentos|acesso_a_direitos|negativa|FALSE|tst
PropoRendaAposentadoriaAcima65anos|Pessoas com 65 anos ou mais com previdencia|acesso_a_direitos|positiva|FALSE|pnadc_anual
Tx_formalizacao|Taxa de formalizacao|acesso_a_direitos|positiva|FALSE|pnadc_trimestral
TxOcupadosRendaAbaixoPOF|Ocupados com renda abaixo da linha da POF|qualidade_remuneracao|negativa|TRUE|pnadc_trimestral
RendimentoRealMedio|Rendimento real medio|qualidade_remuneracao|positiva|TRUE|pnadc_trimestral
SalarioMinimoReal_MM|Salario minimo real|qualidade_remuneracao|positiva|FALSE|ipeadata
MassaRendaHabTodosTrab_noPIB|Massa de rendimentos sobre o PIB|qualidade_remuneracao|positiva|FALSE|sidra_cnt
TxJornadaAcima44h|Jornada acima de 44 horas|qualidade_jornada|negativa|TRUE|pnadc_trimestral
Admitidos_ContratosAtipicos_MM|Contratos atipicos entre os admitidos|qualidade_contratacao|negativa|FALSE|mte_caged
Gini_rendahabTodosTrabalhos|Gini dos rendimentos do trabalho|qualidade_equidade|negativa|FALSE|pnadc_trimestral
Palma90_40_Massa_TodosTrab|Indice de Palma dos rendimentos do trabalho|qualidade_equidade|negativa|FALSE|pnadc_trimestral
RendimentoRealMedio_SexoCor|Razao de rendimento, mulheres negras sobre homens brancos|qualidade_equidade|positiva|FALSE|pnadc_trimestral
PostosDirecao_MulheresNegras|Mulheres negras em postos de direcao|qualidade_equidade|positiva|FALSE|pnadc_trimestral
GrevesPropositivas|Greves propositivas sobre defensivas|qualidade_dialogo_social|positiva|TRUE|dieese
ReajustesAcimaINPC_MM|Acordos com reajuste acima da inflacao|qualidade_dialogo_social|positiva|TRUE|dieese
ConfiancaSindicatos|Confianca nos sindicatos|qualidade_dialogo_social|positiva|FALSE|ipec
AcidentesTrabalho_ponderadoSegurada|Acidentes de trabalho por mil segurados|qualidade_saude_seguranca|negativa|FALSE|inss
AfastamentoRemunerado|Afastamento remunerado por doenca ou acidente|qualidade_saude_seguranca|negativa|FALSE|pnadc_trimestral
PopulacaoSeguradaINSS|Populacao segurada pelo INSS (insumo do indicador de acidentes)|insumo|positiva|FALSE|pnadc_trimestral
', sep = "|")

# ------------------------------------------------------------------------------
# 4. Funcoes de data e serie
# ------------------------------------------------------------------------------

#' Data do primeiro mes de um trimestre.
f_data_tri <- function(ano, tri) {
  as.IDate(sprintf("%d-%02d-01", ano, (tri - 1) * 3 + 1))
}

#' Trimestres disponiveis na pasta de microdados, em ordem cronologica.
#' Devolve strings TTAAAA, como nos nomes dos arquivos.
f_lista_trimestres <- function(dir = DIR_PNADCT, ano_inicio = ANO_INICIO) {
  if (!dir.exists(dir)) return(character(0))
  arq <- list.files(dir, pattern = "^PNADCT_\\d{6}\\.gz$")
  tri <- sub("^PNADCT_(\\d{6})\\.gz$", "\\1", arq)
  tri <- tri[as.integer(substr(tri, 3, 6)) >= ano_inicio]
  tri[order(substr(tri, 3, 6), substr(tri, 1, 2))]
}

#' Tabela de deflatores da PNADC, por Ano, Trimestre e UF.
#' Arquivo de deflator mais recente presente na pasta da fonte.
#' O nome traz ano e meses da base de precos, o que permite ordenar.
f_arquivo_deflator <- function() {
  arqs <- list.files(DIR_FONTE("pnadc_trimestral"),
                     pattern = "^deflator_PNADC.*[.]xlsx?$", full.names = TRUE)
  if (length(arqs) == 0) return(NA_character_)
  chave <- sub("^deflator_PNADC_(\\d{4})_trimestral_(\\d+).*$", "\\1\\2",
               basename(arqs))
  # Arquivos fora do padrao de nome ficam por ultimo.
  chave[chave == basename(arqs)] <- "0"
  arqs[order(chave, decreasing = TRUE)][1]
}

#' Base de precos do deflator, lida do nome do arquivo.
#' deflator_PNADC_2026_trimestral_040506.xls devolve o mes do meio do
#' trimestre de referencia, aqui maio de 2026.
f_base_precos_deflator <- function(arquivo = f_arquivo_deflator()) {
  if (is.na(arquivo)) return(NA)
  m <- regmatches(basename(arquivo),
                  regexec("deflator_PNADC_(\\d{4})_trimestral_(\\d{2})(\\d{2})(\\d{2})",
                          basename(arquivo)))[[1]]
  if (length(m) < 5) return(NA)
  as.Date(sprintf("%s-%s-01", m[2], m[4]))
}

#' Baixa Deflatores.zip do FTP do IBGE e grava o .xls na pasta da fonte, com o
#' nome de origem. Devolve o caminho do arquivo em uso.
#' @param baixar FALSE pula o download e usa o que ja existe.
f_baixa_deflator <- function(baixar = BAIXAR_DEFLATOR) {
  if (baixar) {
    ok <- tryCatch({
      zip_tmp <- tempfile(fileext = ".zip")
      utils::download.file(URL_DEFLATOR, zip_tmp, mode = "wb", quiet = TRUE)
      dentro <- utils::unzip(zip_tmp, list = TRUE)$Name
      destino <- file.path(DIR_FONTE("pnadc_trimestral"), basename(dentro[1]))
      if (file.exists(destino)) {
        message("deflator ja presente: ", basename(destino))
      } else {
        utils::unzip(zip_tmp, exdir = DIR_FONTE("pnadc_trimestral"))
        message("deflator baixado: ", basename(destino))
      }
      TRUE
    }, error = function(e) {
      warning("Falha ao baixar os deflatores (", conditionMessage(e),
              "). Sera usado o arquivo ja presente na pasta.",
              call. = FALSE, immediate. = TRUE)
      FALSE
    })
  }
  arq <- f_arquivo_deflator()
  if (is.na(arq)) {
    stop("Nenhum deflator em ", DIR_FONTE("pnadc_trimestral"),
         ". Baixe ", URL_DEFLATOR, " e descompacte nessa pasta.")
  }
  arq
}

f_le_deflator <- function(arquivo = f_arquivo_deflator()) {
  if (is.na(arquivo) || !file.exists(arquivo)) {
    stop("Deflator nao encontrado em ", arquivo,
         "\nVeja dados/pnadc_trimestral/LEIAME.md.")
  }
  d <- as.data.table(readxl::read_excel(arquivo))
  trimestres <- c("01-02-03", "04-05-06", "07-08-09", "10-11-12")
  d <- d[trim %in% trimestres]
  d[, `:=`(Ano       = as.integer(Ano),
           Trimestre = match(trim, trimestres),
           UF        = as.integer(UF))]
  d[, .(Ano, Trimestre, UF, Habitual, Efetivo)]
}

#' Media movel de 12 periodos, alinhada a direita.
f_mm12 <- function(x) {
  zoo::rollapply(x, width = 12, FUN = mean, align = "right", fill = NA, na.rm = TRUE)
}

#' Interpola linearmente para preencher a grade de datas.
#' @param d data.table com colunas data e valor.
#' @param por "month" ou "quarter".
f_interpola <- function(d, por = "quarter") {
  d <- as.data.table(d)[order(data)]
  grade <- data.table(data = as.IDate(seq(min(d$data), max(d$data), by = por)))
  d <- merge(grade, d, by = "data", all.x = TRUE)
  d[, valor := zoo::na.approx(valor, na.rm = FALSE)]
  d[!is.na(valor)]
}

# ------------------------------------------------------------------------------
# 5. Validacao
# ------------------------------------------------------------------------------

#' Checa uma serie antes de gravar. Para a execucao quando o problema impede o
#' uso da serie e avisa quando apenas merece conferencia.
#' @param d data.table com colunas data e valor.
#' @param nome nome da serie.
#' @param faixa intervalo plausivel dos valores.
#' @param var_max variacao absoluta maxima aceitavel entre pontos vizinhos.
#' @param freq "quarter" ou "month"; verifica buracos na grade de datas.
f_valida_serie <- function(d, nome, faixa = c(-Inf, Inf), var_max = Inf,
                           freq = "quarter") {
  d <- as.data.table(d)[order(data)]

  if (nrow(d) == 0) stop("[", nome, "] serie vazia.")
  if (anyNA(d$valor)) stop("[", nome, "] ha valores ausentes.")
  if (anyDuplicated(d$data)) stop("[", nome, "] ha datas repetidas.")

  fora <- d[valor < faixa[1] | valor > faixa[2]]
  if (nrow(fora)) {
    stop("[", nome, "] ", nrow(fora), " valores fora da faixa plausivel [",
         faixa[1], ", ", faixa[2], "]. Primeiro: ", format(fora$data[1]),
         " = ", round(fora$valor[1], 4))
  }

  grade <- seq(min(d$data), max(d$data), by = freq)
  buracos <- setdiff(as.character(grade), as.character(d$data))
  if (length(buracos)) {
    warning("[", nome, "] ", length(buracos), " datas faltando na grade ", freq,
            ". Primeira: ", buracos[1], call. = FALSE, immediate. = TRUE)
  }

  if (nrow(d) > 1 && is.finite(var_max)) {
    salto <- d[, max(abs(diff(valor)))]
    if (salto > var_max) {
      warning("[", nome, "] salto de ", round(salto, 4),
              " entre pontos vizinhos, acima do esperado (", var_max, ").",
              " Confira se houve quebra de serie.", call. = FALSE,
              immediate. = TRUE)
    }
  }

  invisible(d)
}

# ------------------------------------------------------------------------------
# 6. Gravacao, manifesto e graficos
# ------------------------------------------------------------------------------

#' Grava uma serie no formato longo do projeto (data, variavel, valor).
f_grava_serie <- function(d, nome) {
  d <- as.data.table(d)[, .(data = as.IDate(data), variavel = nome, valor)]
  setorder(d, data)
  fwrite(d, file.path(DIR_SERIES, paste0(nome, ".csv")),
         sep = ";", dec = ",", bom = TRUE)
  message("  serie gravada: ", nome, " (", nrow(d), " pontos, ",
          format(min(d$data)), " a ", format(max(d$data)), ")")
  invisible(d)
}

#' Le uma serie ja gravada.
f_le_serie <- function(nome) {
  arq <- file.path(DIR_SERIES, paste0(nome, ".csv"))
  if (!file.exists(arq)) stop("Serie ausente: ", nome, ". Rode o script que a produz.")
  d <- fread(arq, dec = ",")
  d[, data := as.IDate(data)][]
}

#' Registra no manifesto de dados o arquivo usado nesta rodada.
#' @param fonte pasta da fonte, como em dados/<fonte>.
#' @param arquivo caminho do arquivo usado.
#' @param tipo "api", "bruto", "manual" ou "congelado".
#' @param origem URL ou descricao de como foi obtido.
f_registra_manifesto <- function(fonte, arquivo, tipo, origem) {
  arq_man <- file.path(DIR_DADOS, "MANIFESTO.csv")
  novo <- data.table(
    fonte      = fonte,
    arquivo    = basename(arquivo),
    tipo       = tipo,
    origem     = origem,
    modificado = if (file.exists(arquivo))
      format(file.info(arquivo)$mtime, "%Y-%m-%d") else NA_character_,
    bytes      = if (file.exists(arquivo)) file.info(arquivo)$size else NA_real_,
    md5        = if (file.exists(arquivo)) tools::md5sum(arquivo)[[1]] else NA_character_,
    registrado = format(Sys.time(), "%Y-%m-%d %H:%M"))

  if (file.exists(arq_man)) {
    antigo <- fread(arq_man, colClasses = "character")
    antigo <- antigo[!(fonte == novo$fonte & arquivo == novo$arquivo)]
    # Remove registros de arquivos que nao existem mais. Consultas de API nao
    # tem arquivo em disco e por isso sao mantidas.
    if (nrow(antigo)) {
      existe <- mapply(function(f, a) {
        length(list.files(file.path(DIR_DADOS, f), pattern = paste0("^", a, "$"),
                          recursive = TRUE)) > 0
      }, antigo$fonte, antigo$arquivo)
      antigo <- antigo[tipo == "api" | existe]
    }
    novo <- rbind(antigo, novo, fill = TRUE)
  }
  fwrite(novo, arq_man, sep = ";", bom = TRUE)
  invisible(novo)
}

#' Tema dos graficos.
tema_itd <- ggplot2::theme_bw() +
  ggplot2::theme(
    text            = ggplot2::element_text(size = 12),
    plot.title      = ggplot2::element_text(face = "bold", size = 12),
    legend.title    = ggplot2::element_blank(),
    legend.position = "bottom",
    axis.text       = ggplot2::element_text(colour = "black"))

#' Grafico de linha de uma serie, salvo em output/IMG.
f_grafico_serie <- function(d, nome, titulo = nome, percentual = TRUE) {
  g <- ggplot2::ggplot(d, ggplot2::aes(as.Date(data), valor)) +
    ggplot2::geom_line(linewidth = 1) +
    ggplot2::scale_x_date(date_breaks = "2 years", date_labels = "%Y") +
    ggplot2::labs(title = titulo, x = NULL, y = NULL,
                  caption = "Fonte: elaboracao propria. Projeto ITD.") +
    tema_itd
  if (percentual) g <- g + ggplot2::scale_y_continuous(labels = scales::percent_format())
  ggplot2::ggsave(file.path(DIR_IMG, paste0(nome, ".png")), g,
                  width = 8, height = 5, dpi = 150)
  g
}


# ------------------------------------------------------------------------------
# 7. Download de microdados
#    Controlam se os scripts podem buscar microdados pela internet quando o
#    arquivo local nao existe. Veja dados/pnadc_*/LEIAME.md.
# ------------------------------------------------------------------------------

# Baixar o Deflatores.zip do FTP do IBGE a cada rodada.
BAIXAR_DEFLATOR <- TRUE

# Trimestres da PNADC-T ausentes em DIR_PNADCT sao buscados pelo PNADcIBGE.
BAIXAR_PNADCT <- TRUE

# Anos da PNADC Anual ausentes em DIR_PNADCA_* sao buscados pelo PNADcIBGE.
# Padrao FALSE: o download anual e pesado e a serie nao entra no IDH-T.
BAIXAR_PNADCA <- FALSE

# Microdados do Novo CAGED (CAGEDMOV<anomes>.7z). Pasta local, no layout do
# PDET (<ano>/<anomes>/). Vazio significa que so o download e a Base dos Dados
# sao usados. Veja dados/mte_caged/LEIAME.md.
DIR_CAGED_MICRO <- "C:/caminho/para/CAGED/DATA"

# FTP do MTE para os microdados do Novo CAGED.
URL_CAGED_FTP <- "ftp://ftp.mtps.gov.br/pdet/microdados/NOVO CAGED/"

# Baixar meses ausentes do CAGED pelo FTP. O arquivo mensal tem cerca de 100 MB.
BAIXAR_CAGED <- TRUE

# ------------------------------------------------------------------------------
# 8. Configuracao local
#    R/config_local.R guarda os caminhos desta maquina e nao e versionado.
#    O que estiver la tem prioridade sobre os valores acima.
# ------------------------------------------------------------------------------

ARQ_CONFIG_LOCAL <- file.path(DIR_RAIZ, "R", "config_local.R")
if (file.exists(ARQ_CONFIG_LOCAL)) {
  source(ARQ_CONFIG_LOCAL, local = FALSE)
  message("config_local.R carregado")
} else {
  warning("R/config_local.R ausente: os caminhos de microdados estao nos ",
          "valores de exemplo. Copie R/config_local_exemplo.R e ajuste.",
          call. = FALSE, immediate. = TRUE)
}

message("00_config.R carregado. Raiz: ", DIR_RAIZ)

# ------------------------------------------------------------------------------
# 9. Tratamento das series anuais
#    Greves, confianca nos sindicatos e cobertura previdenciaria 65+ sao anuais,
#    e o painel do indice e trimestral.
#
#    "interpolar": liga os pontos anuais por interpolacao linear. Suaviza a
#      passagem entre anos, mas sugere uma trajetoria dentro do ano que nao foi
#      medida, e o ultimo ano entra so com o primeiro trimestre.
#    "repetir" (adotado): repete o valor do ano nos quatro trimestres.
#      caracteristica do ano, que e o que ele e, e cobre o ano inteiro assim que
#      o valor existe. Cria degraus na virada do ano.
# ------------------------------------------------------------------------------

TRATAMENTO_ANUAL <- "repetir"

#' Leva uma serie anual para a frequencia trimestral.
#' @param d data.table com colunas data (1 de janeiro) e valor.
#' @param modo "interpolar" ou "repetir".
f_anual_para_trimestre <- function(d, modo = TRATAMENTO_ANUAL) {
  d <- as.data.table(d)[order(data)]
  if (!modo %in% c("interpolar", "repetir")) {
    stop("TRATAMENTO_ANUAL invalido: ", modo)
  }
  if (modo == "interpolar") return(f_interpola(d, por = "quarter"))

  r <- rbindlist(lapply(seq_len(nrow(d)), function(i) {
    data.table(data = f_data_tri(as.integer(format(d$data[i], "%Y")), 1:4),
               valor = d$valor[i])
  }))
  r[order(data)]
}
