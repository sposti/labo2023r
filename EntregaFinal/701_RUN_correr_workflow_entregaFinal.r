# Corrida general del workflow Semillerio

options(error = function() {
  traceback(20)
  options(error = NULL)
  stop("exiting after script error")
})


# corrida de cada paso del workflow
source("~/labo2023r/EntregaFinal/021sp/701_RUN_correr_workflow.r")
source("~/labo2023r/EntregaFinal/039sp/701_RUN_correr_workflow.r")
source("~/labo2023r/EntregaFinal/039sp/781_ZZ_semillerios_hibridacion.r")

