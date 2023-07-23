# Corrida general del workflow Semillerio

options(error = function() {
  traceback(20)
  options(error = NULL)
  stop("exiting after script error")
})


# corrida de cada paso del workflow

source("~/labo2023r/src/workflow-semillerio/023sp/741_TS_training_strategy.r")
source("~/labo2023r/src/workflow-semillerio/023sp/751_HT_lightgbm.r")
source("~/labo2023r/src/workflow-semillerio/023sp/771_ZZ_final_semillerio.r")