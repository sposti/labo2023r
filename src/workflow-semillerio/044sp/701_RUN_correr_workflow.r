# Corrida general del workflow Semillerio

options(error = function() {
  traceback(20)
  options(error = NULL)
  stop("exiting after script error")
})


# corrida de cada paso del workflow   TOMO DEL 041_SP
source("~/labo2023r/src/workflow-semillerio/044sp/711_CA_reparar_dataset.r")
source("~/labo2023r/src/workflow-semillerio/044sp/721_DR_corregir_drifting.r")
source("~/labo2023r/src/workflow-semillerio/044sp/731_FE_historia.r")
source("~/labo2023r/src/workflow-semillerio/044sp/741_TS_training_strategy.r")
source("~/labo2023r/src/workflow-semillerio/044sp/751_HT_lightgbm.r")
source("~/labo2023r/src/workflow-semillerio/044sp/771_ZZ_final_semillerio.r")