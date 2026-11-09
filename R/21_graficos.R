# Refaz todos os graficos de output/IMG a partir das series ja gravadas em
# output/series, sem tocar nos dados. Serve para quando muda so a aparencia
# (escala do eixo, tema, rotulo), caso em que rodar run_all.Rmd seria desperdicio:
# ele refaz downloads, consultas de API e leitura dos PDF do DIEESE.
#
# Uso, a partir da raiz do pacote:
#   Rscript R/21_graficos.R
#
# Depois, se a documentacao precisar sair com as figuras novas:
#   rmarkdown::render("ITD_fontes_metodologia.Rmd")

if (!exists("DIR_RAIZ")) source("R/00_config.R")

arqs <- list.files(DIR_SERIES, pattern = "[.]csv$", full.names = TRUE)
if (length(arqs) == 0) {
  stop("Nenhuma serie em ", DIR_SERIES, ". Rode run_all.Rmd antes.")
}

for (arq in arqs) {
  nome <- sub("[.]csv$", "", basename(arq))
  d <- data.table::fread(arq, dec = ",", encoding = "UTF-8")
  data.table::setnames(d, 1, "data")
  d[, data := as.IDate(data)]
  data.table::setorder(d, data)
  f_grafico_serie(d[, .(data, valor)], nome)
  cat("figura refeita:", nome, "|", nrow(d), "pontos\n")
}

cat("\n", length(arqs), "figuras em ", DIR_IMG, "\n", sep = "")
