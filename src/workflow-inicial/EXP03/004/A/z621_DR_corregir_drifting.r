# Experimentos Colaborativos Default
# Workflow  Data Drifting repair

# limpio la memoria
rm(list = ls(all.names = TRUE)) # remove all objects
gc(full = TRUE) # garbage collection

require("data.table")
require("yaml")


# Parametros del script
PARAM <- list()
PARAM$experimento <- "DR6210_E3"

PARAM$exp_input <- "CA6110_E3"

PARAM$variables_intrames <- TRUE # atencion esto esta en TRUE

# valores posibles
#  "ninguno", "rank_simple", "rank_cero_fijo", "deflacion"
PARAM$metodo <- "rank_cero_fijo"

PARAM$home <- "~/buckets/b1/"
# FIN Parametros del script

OUTPUT <- list()

#------------------------------------------------------------------------------

options(error = function() {
  traceback(20)
  options(error = NULL)
  stop("exiting after script error")
})
#------------------------------------------------------------------------------

GrabarOutput <- function() {
  write_yaml(OUTPUT, file = "output.yml") # grabo output
}
#------------------------------------------------------------------------------
# Esta es la parte que los alumnos deben desplegar todo su ingenio
# Agregar aqui sus PROPIAS VARIABLES manuales

AgregarVariables_IntraMes <- function(dataset) {
  gc()
  # INICIO de la seccion donde se deben hacer cambios con variables nuevas

  # creo un ctr_quarter que tenga en cuenta cuando
  # los clientes hace 3 menos meses que estan
  dataset[, ctrx_quarter_normalizado := ctrx_quarter]
  dataset[cliente_antiguedad == 1, ctrx_quarter_normalizado := ctrx_quarter * 5]
  dataset[cliente_antiguedad == 2, ctrx_quarter_normalizado := ctrx_quarter * 2]
  dataset[
    cliente_antiguedad == 3,
    ctrx_quarter_normalizado := ctrx_quarter * 1.2
  ]

  # variable extraida de una tesis de maestria de Irlanda
  dataset[, mpayroll_sobre_edad := mpayroll / cliente_edad]

  # se crean los nuevos campos para MasterCard  y Visa,
  #  teniendo en cuenta los NA's
  # varias formas de combinar Visa_status y Master_status
  dataset[, vm_status01 := pmax(Master_status, Visa_status, na.rm = TRUE)]
  dataset[, vm_status02 := Master_status + Visa_status]

  dataset[, vm_status03 := pmax(
    ifelse(is.na(Master_status), 10, Master_status),
    ifelse(is.na(Visa_status), 10, Visa_status)
  )]

  dataset[, vm_status04 := ifelse(is.na(Master_status), 10, Master_status)
    + ifelse(is.na(Visa_status), 10, Visa_status)]

  dataset[, vm_status05 := ifelse(is.na(Master_status), 10, Master_status)
    + 100 * ifelse(is.na(Visa_status), 10, Visa_status)]

  dataset[, vm_status06 := ifelse(is.na(Visa_status),
    ifelse(is.na(Master_status), 10, Master_status),
    Visa_status
  )]

  dataset[, mv_status07 := ifelse(is.na(Master_status),
    ifelse(is.na(Visa_status), 10, Visa_status),
    Master_status
  )]


  # combino MasterCard y Visa
  dataset[, vm_mfinanciacion_limite := rowSums(cbind(Master_mfinanciacion_limite, Visa_mfinanciacion_limite), na.rm = TRUE)]

  dataset[, vm_Fvencimiento := pmin(Master_Fvencimiento, Visa_Fvencimiento, na.rm = TRUE)]
  dataset[, vm_Finiciomora := pmin(Master_Finiciomora, Visa_Finiciomora, na.rm = TRUE)]
  dataset[, vm_msaldototal := rowSums(cbind(Master_msaldototal, Visa_msaldototal), na.rm = TRUE)]
  dataset[, vm_msaldopesos := rowSums(cbind(Master_msaldopesos, Visa_msaldopesos), na.rm = TRUE)]
  dataset[, vm_msaldodolares := rowSums(cbind(Master_msaldodolares, Visa_msaldodolares), na.rm = TRUE)]
  dataset[, vm_mconsumospesos := rowSums(cbind(Master_mconsumospesos, Visa_mconsumospesos), na.rm = TRUE)]
  dataset[, vm_mconsumosdolares := rowSums(cbind(Master_mconsumosdolares, Visa_mconsumosdolares), na.rm = TRUE)]
  dataset[, vm_mlimitecompra := rowSums(cbind(Master_mlimitecompra, Visa_mlimitecompra), na.rm = TRUE)]
  dataset[, vm_madelantopesos := rowSums(cbind(Master_madelantopesos, Visa_madelantopesos), na.rm = TRUE)]
  dataset[, vm_madelantodolares := rowSums(cbind(Master_madelantodolares, Visa_madelantodolares), na.rm = TRUE)]
  dataset[, vm_fultimo_cierre := pmax(Master_fultimo_cierre, Visa_fultimo_cierre, na.rm = TRUE)]
  dataset[, vm_mpagado := rowSums(cbind(Master_mpagado, Visa_mpagado), na.rm = TRUE)]
  dataset[, vm_mpagospesos := rowSums(cbind(Master_mpagospesos, Visa_mpagospesos), na.rm = TRUE)]
  dataset[, vm_mpagosdolares := rowSums(cbind(Master_mpagosdolares, Visa_mpagosdolares), na.rm = TRUE)]
  dataset[, vm_fechaalta := pmax(Master_fechaalta, Visa_fechaalta, na.rm = TRUE)]
  dataset[, vm_mconsumototal := rowSums(cbind(Master_mconsumototal, Visa_mconsumototal), na.rm = TRUE)]
  dataset[, vm_cconsumos := rowSums(cbind(Master_cconsumos, Visa_cconsumos), na.rm = TRUE)]
  dataset[, vm_cadelantosefectivo := rowSums(cbind(Master_cadelantosefectivo, Visa_cadelantosefectivo), na.rm = TRUE)]
  dataset[, vm_mpagominimo := rowSums(cbind(Master_mpagominimo, Visa_mpagominimo), na.rm = TRUE)]

  # a partir de aqui juego con la suma de Mastercard y Visa
  dataset[, vmr_Master_mlimitecompra := Master_mlimitecompra / vm_mlimitecompra]
  dataset[, vmr_Visa_mlimitecompra := Visa_mlimitecompra / vm_mlimitecompra]
  dataset[, vmr_msaldototal := vm_msaldototal / vm_mlimitecompra]
  dataset[, vmr_msaldopesos := vm_msaldopesos / vm_mlimitecompra]
  dataset[, vmr_msaldopesos2 := vm_msaldopesos / vm_msaldototal]
  dataset[, vmr_msaldodolares := vm_msaldodolares / vm_mlimitecompra]
  dataset[, vmr_msaldodolares2 := vm_msaldodolares / vm_msaldototal]
  dataset[, vmr_mconsumospesos := vm_mconsumospesos / vm_mlimitecompra]
  dataset[, vmr_mconsumosdolares := vm_mconsumosdolares / vm_mlimitecompra]
  dataset[, vmr_madelantopesos := vm_madelantopesos / vm_mlimitecompra]
  dataset[, vmr_madelantodolares := vm_madelantodolares / vm_mlimitecompra]
  dataset[, vmr_mpagado := vm_mpagado / vm_mlimitecompra]
  dataset[, vmr_mpagospesos := vm_mpagospesos / vm_mlimitecompra]
  dataset[, vmr_mpagosdolares := vm_mpagosdolares / vm_mlimitecompra]
  dataset[, vmr_mconsumototal := vm_mconsumototal / vm_mlimitecompra]
  dataset[, vmr_mpagominimo := vm_mpagominimo / vm_mlimitecompra]

  # Aqui debe usted agregar sus propias nuevas variables
  # variables nuevas: cociente de las 5 "primer orden" + importantes del E1
  
  #numeradores/
  #ctrx_quarter_normalizado 
  dataset[, impo_01 := ctrx_quarter_normalizado / ctrx_quarter]
  dataset[, impo_02 := ctrx_quarter_normalizado / Visa_status]
  dataset[, impo_03 := ctrx_quarter_normalizado / vm_status05]
  dataset[, impo_04 := ctrx_quarter_normalizado / vm_status01]
  dataset[, impo_05 := ctrx_quarter_normalizado / vmr_mpagominimo]
  
  #ctrx_quarter/
  dataset[, impo_06 := ctrx_quarter / ctrx_quarter_normalizado]
  dataset[, impo_07 := ctrx_quarter / Visa_status]
  dataset[, impo_08 := ctrx_quarter / vm_status05]
  dataset[, impo_09 := ctrx_quarter / vm_status01]
  dataset[, impo_10 := ctrx_quarter / vmr_mpagominimo]
  
  
  #visa_status/
  dataset[, impo_11 := Visa_status / ctrx_quarter_normalizado]
  dataset[, impo_12 := Visa_status / ctrx_quarter ]
  dataset[, impo_13 := Visa_status / vm_status05]
  dataset[, impo_14 := Visa_status / vm_status01]
  dataset[, impo_15 := Visa_status / vmr_mpagominimo]
  
  #visa_status05/
  dataset[, impo_16 := vm_status05 / ctrx_quarter_normalizado]
  dataset[, impo_17 := vm_status05 / ctrx_quarter ]
  dataset[, impo_18 := vm_status05 / Visa_status]
  dataset[, impo_19 := vm_status05 / vm_status01]
  dataset[, impo_20 := vm_status05 / vmr_mpagominimo]
  
  #visa_status01/
  dataset[, impo_21 := vm_status01 / ctrx_quarter_normalizado]
  dataset[, impo_22 := vm_status01 / ctrx_quarter ]
  dataset[, impo_23 := vm_status01 / Visa_status]
  dataset[, impo_24 := vm_status01 / vm_status05]
  dataset[, impo_25 := vm_status01 / vmr_mpagominimo]
  
  #vmr_mpagominimo/
  dataset[, impo_26 := vmr_mpagominimo / ctrx_quarter_normalizado]
  dataset[, impo_27 := vmr_mpagominimo / ctrx_quarter ]
  dataset[, impo_28 := vmr_mpagominimo / Visa_status]
  dataset[, impo_29 := vmr_mpagominimo / vm_status05]
  dataset[, impo_30 := vmr_mpagominimo / vm_status01]
  
  #Sp
  dataset[, vmr_pagominimo_saldo := rowSums(cbind(ifelse(vm_msaldototal == 0, 0, vm_mpagominimo / vm_msaldototal)), na.rm = TRUE)] #ratio utilizacion TC
  dataset[, c_deb_aut := rowSums(cbind(ccuenta_debitos_automaticos, ctarjeta_visa_debitos_automaticos, ctarjeta_master_debitos_automaticos), na.rm = TRUE)] #campo debitos autmaticos
  dataset[, m_deb_aut := rowSums(cbind(mcuenta_debitos_automaticos, mttarjeta_visa_debitos_automaticos, mttarjeta_master_debitos_automaticos), na.rm = TRUE)] #campo debitos autmaticos
  dataset[, c_pagos := rowSums(cbind(cpagodeservicios, cpagomiscuentas), na.rm = TRUE)] #campo pagos no automaticos voluntarios cantidad
  dataset[, m_pagos := rowSums(cbind(mpagodeservicios, mpagomiscuentas), na.rm = TRUE)] #campo pagos no automaticos voluntarios  monto
  dataset[, c_seguros := rowSums(cbind(cseguro_vida, cseguro_auto, cseguro_vivienda, cseguro_accidentes_personales), na.rm = TRUE)] #campo pagos no automaticos voluntarios  monto
  dataset[, estado := rowSums(cbind(Master_status + Visa_status), na.rm = TRUE)] #
  dataset[, vm_status_SP := ifelse(is.na(Master_status), 0, Master_status) + ifelse(is.na(Visa_status), 0, Visa_status)] #status que empeora si la TC está en proceso de baja o dada de baja. El no tener no suma complejidad.
  dataset[, contactos := rowSums(cbind(ccajas_consultas, ccajas_depositos, ccajas_extracciones, ccajas_otras, cextraccion_autoservicio, ccheques_depositados, ccallcenter_transacciones), na.rm = TRUE)] #
  dataset[, visitas := rowSums(cbind(ccajas_consultas, ccajas_depositos, ccajas_extracciones, ccajas_otras, cextraccion_autoservicio, ccheques_depositados), na.rm = TRUE)] #
  dataset[, cajas_visitas := rowSums(cbind(ccajas_consultas, ccajas_depositos, ccajas_extracciones, ccajas_otras), na.rm = TRUE)] #
  dataset[, cajas_ratio_01 := rowSums(cbind(ifelse(cajas_visitas == 0, 0, ccajas_consultas / cajas_visitas)), na.rm = TRUE)] #
  dataset[, cajas_ratio_02 := rowSums(cbind(ifelse(cajas_visitas == 0, 0, ccajas_depositos / cajas_visitas)), na.rm = TRUE)] #
  dataset[, cajas_ratio_03 := rowSums(cbind(ifelse(cajas_visitas == 0, 0, ccajas_extracciones / cajas_visitas)), na.rm = TRUE)] #
  dataset[, cajas_ratio_04 := rowSums(cbind(ifelse(cajas_visitas == 0, 0, ccajas_otras / cajas_visitas)), na.rm = TRUE)] #
  dataset[, c_tax := rowSums(cbind(cpagodeservicios, cpagomiscuentas), na.rm = TRUE)] #campo debitos autmaticos
  dataset[, m_tax := rowSums(cbind(mpagodeservicios, mpagomiscuentas), na.rm = TRUE)] #campo debitos autmaticos
  dataset[, hb_cajas := rowSums(cbind(ifelse(cajas_visitas == 0, 0, chomebanking_transacciones / cajas_visitas)), na.rm = TRUE)] #
  dataset[, m_inversiones := rowSums(cbind(mplazo_fijo_dolares, mplazo_fijo_pesos, minversion1_pesos, minversion1_dolares, minversion2), na.rm = TRUE)] #
  dataset[, atm_ratio_c := rowSums(cbind(ifelse((catm_trx + catm_trx_other) == 0, 0, catm_trx / (catm_trx + catm_trx_other))), na.rm = TRUE)] #
  dataset[, atm_ratio_eme := rowSums(cbind(ifelse((matm + matm_other) == 0, 0, matm / (matm + matm_other))), na.rm = TRUE)] #
  dataset[, c_e_sp := rowSums(cbind(ctarjeta_debito_transacciones, ctarjeta_visa_transacciones, ctarjeta_master_transacciones, cpagodeservicios, ctransferencias_emitidas, cextraccion_autoservicio, ccheques_emitidos, ccheques_depositados_rechazados, ccheques_emitidos_rechazados, ccajas_extracciones, ccomisiones_otras), na.rm = TRUE)] #
  dataset[, m_e_sp := rowSums(cbind(mtarjeta_visa_consumo, mtarjeta_master_consumo, mcuenta_debitos_automaticos, mttarjeta_visa_debitos_automaticos, mttarjeta_master_debitos_automaticos, mpagodeservicios, mpagomiscuentas, mcomisiones_mantenimiento, mcomisiones_otras, mtransferencias_emitidas, mextraccion_autoservicio, mcheques_emitidos, mcheques_depositados_rechazados, mcheques_emitidos_rechazados), na.rm = TRUE)] #
  dataset[, c_y_sp := rowSums(cbind(cpayroll_trx, cpayroll2_trx, ctransferencias_recibidas, ccheques_depositados, ccajas_depositos), na.rm = TRUE)] #
  dataset[, m_y_sp := rowSums(cbind(mpayroll, mpayroll2, mtransferencias_recibidas, mcheques_depositados), na.rm = TRUE)] #
  dataset[, c_p_sp := rowSums(cbind(ccajeros_propios_descuentos, ctarjeta_visa_descuentos, ctarjeta_master_descuentos), na.rm = TRUE)] #
  dataset[, m_p_sp := rowSums(cbind(mcajeros_propios_descuentos, mtarjeta_visa_descuentos, mtarjeta_master_descuentos), na.rm = TRUE)] #
  dataset[, e_y_ratio := rowSums(cbind(ifelse(m_y_sp == 0, 0, m_e_sp / m_y_sp)), na.rm = TRUE)] #
  dataset[, c_e_y_ratio := rowSums(cbind(ifelse(c_y_sp == 0, 0, c_e_sp / c_y_sp)), na.rm = TRUE)] #
  dataset[, p_y_ratio := rowSums(cbind(ifelse(m_y_sp == 0, 0, m_p_sp / m_y_sp)), na.rm = TRUE)] #
  dataset[, p_e_ratio := rowSums(cbind(ifelse(m_e_sp == 0, 0, m_p_sp / m_e_sp)), na.rm = TRUE)] #
  dataset[, seguros_ratio_01 := rowSums(cbind(ifelse(c_e_sp == 0, 0, c_seguros / c_e_sp)), na.rm = TRUE)] #
  dataset[, c_anclaje_pesado := rowSums(cbind(cprestamos_personales, cprestamos_prendarios, cprestamos_hipotecarios), na.rm = TRUE)] #
  dataset[, m_anclaje_pesado := rowSums(cbind(mprestamos_personales, mprestamos_prendarios, mprestamos_hipotecarios), na.rm = TRUE)] #
  dataset[, c_ganchos_liviano := rowSums(cbind(cplazo_fijo, cinversion1, cinversion2), na.rm = TRUE)] #
  dataset[, m_ganchos_liviano := rowSums(cbind(mplazo_fijo_dolares, mplazo_fijo_pesos, minversion1_pesos, minversion1_dolares, minversion2), na.rm = TRUE)] #
  dataset[, c_ganchos_anclaje_ratio := rowSums(cbind(ifelse(c_anclaje_pesado == 0, 0, c_ganchos_liviano / c_anclaje_pesado)), na.rm = TRUE)] #
  dataset[, ganchos_anclaje_ratio := rowSums(cbind(ifelse(m_anclaje_pesado == 0, 0, m_ganchos_liviano / m_anclaje_pesado)), na.rm = TRUE)] #
  
  #ml
  
  
  #1. cuentas
  dataset[, monto_tot_CC_CA:= mcuenta_corriente_adicional + mcuenta_corriente + mcaja_ahorro+ mcaja_ahorro_adicional+mcuenta_corriente_adicional]
  dataset[, prop_cc_adic := mcuenta_corriente_adicional / monto_tot_CC_CA]
  dataset[, prop_cc := mcuenta_corriente / monto_tot_CC_CA]
  dataset[, prop_ca := mcaja_ahorro/ monto_tot_CC_CA]
  dataset[, prop_ca_adic := mcaja_ahorro_adicional / monto_tot_CC_CA]
  dataset[, prop_ca_usd := mcaja_ahorro_dolares / monto_tot_CC_CA]
  dataset[, prop_cc_adic := mcuenta_corriente_adicional / monto_tot_CC_CA]
  
  #2 TC
  dataset[, cTC_transacciones := ctarjeta_visa_transacciones + ctarjeta_master_transacciones]
  dataset[, mTC_transacciones := mtarjeta_visa_consumo + mtarjeta_master_consumo]
  
  #3 Prestamos
  dataset[, cant_Prestamos := cprestamos_personales + cprestamos_prendarios + cprestamos_hipotecarios]
  dataset[, monto_Prestamos := mprestamos_personales + mprestamos_prendarios + mprestamos_hipotecarios]
  
  
  dataset[, prop_PP := cprestamos_personales /  cant_Prestamos]
  dataset[, prop_montoPP := mprestamos_personales /  monto_Prestamos]
  
  dataset[, prop_Pprend := cprestamos_prendarios /  cant_Prestamos]
  dataset[, Prop_montoPprend := mprestamos_prendarios /  monto_Prestamos]
  
  dataset[, prop_PH := cprestamos_hipotecarios /  cant_Prestamos]
  dataset[, Prop_montoPH := mprestamos_hipotecarios /  monto_Prestamos]
  
  #4 inversiones
  
  dataset[, mtotal_PF := mplazo_fijo_dolares +  mplazo_fijo_pesos]
  dataset[, prom_mPF := mtotal_PF / cplazo_fijo]
  dataset[, prop_PFUSD := mplazo_fijo_dolares / mtotal_PF]
  dataset[, prop_PFpesos := mplazo_fijo_pesos / mtotal_PF]
  
  dataset[, minversion1_total := minversion1_pesos +  minversion1_dolares]
  
  dataset[, cinversion_total := cinversion1 +  cinversion2]
  dataset[, minversion_total := minversion1_total +  minversion2]
  dataset[, minversion1_total := minversion1_pesos +  minversion1_dolares]
  
  dataset[, cinversion_total_2 := cplazo_fijo +  cinversion_total]
  dataset[, minversion_total_2 := minversion_total +  mtotal_PF ]
  dataset[, minversion1_total := minversion1_pesos +  minversion1_dolares]
  
  dataset[, prom_m_inv2 := minversion2/ cinversion2] 
  dataset[, prom_m_inv_total_2 := minversion_total_2/ cinversion_total_2] 
  
  dataset[, prom_m_inv1 := minversion1_total / minversion1_total]
  dataset[, prom_m_inv1 := minversion1_total / minversion1_total]
  
  
  #5 seguros
  
  dataset[, csegurototal := cseguro_vida + cseguro_auto + cseguro_vivienda + cseguro_accidentes_personales]
  dataset[, prop_cseguro_vida := cseguro_vida / csegurototal ]
  dataset[, prop_cseguro_auto := cseguro_auto / csegurototal ]
  dataset[, prop_cseguro_vivienda := cseguro_vivienda/ csegurototal ]
  dataset[, prop_cseguro_accidentes_personales := cseguro_accidentes_personales / csegurototal ]
  
  #6 empleados
  dataset[, m_acred_total := mpayroll + mpayroll2]
  dataset[, prop_acred_payroll := mpayroll / m_acred_total]
  
  
  #7 debitos autom
  dataset[, monto_tot_debaut := mcuenta_debitos_automaticos + mttarjeta_visa_debitos_automaticos + mttarjeta_master_debitos_automaticos]
  dataset[, cant_tot_deb_aut := ccuenta_debitos_automaticos + ctarjeta_visa_debitos_automaticos + ctarjeta_master_debitos_automaticos]
  dataset[, prom_deb_aut := monto_tot_debaut/ cant_tot_deb_aut]
  
  #8 servicios
  dataset[, cpagos_tot := cpagodeservicios + cpagomiscuentas]
  dataset[, mpagos_tot := mpagodeservicios + mpagomiscuentas]
  dataset[, prop_pagos_tot := mpagos_tot/ cpagos_tot]
  dataset[, ratio_pagos_ingreso := mpagos_tot/ m_acred_total]
  
  #9 descuentos
  dataset[, mtc_total_descuentos := mtarjeta_visa_descuentos+ mtarjeta_master_descuentos]
  dataset[, ctc_total_descuentos := ctarjeta_visa_descuentos+ ctarjeta_master_descuentos]
  dataset[, neto_consumo_visa:= mtarjeta_visa_consumo-mtarjeta_visa_descuentos]
  dataset[, neto_consumo_master := mtarjeta_master_consumo-mtarjeta_master_descuentos] 
  dataset[, neto_consumo_tc:= mTC_transacciones-mtc_total_descuentos] 
  dataset[, ratio_tcvisa_ingresos := neto_consumo_visa/ m_acred_total]
  dataset[, ratio_tcmaster_ingresos := neto_consumo_master/ m_acred_total]
  dataset[, ratio_tc_ingresos := neto_consumo_tc/ m_acred_total]
  
  #10 comisiones
  dataset[, ccomisiones_tot:= ccomisiones_mantenimiento+ ccomisiones_otras]
  dataset[, mcomisiones_tot := mcomisiones_mantenimiento+ ccomisiones_otras]
  dataset[, prop_comisiones_mant := mcomisiones_mantenimiento/ccomisiones_tot]
  dataset[, prop_comisiones_otras := mcomisiones_otras/ccomisiones_tot]
  dataset[, prom_comisiones_tot := mcomisiones_tot/ccomisiones_tot]
  
  
  # valvula de seguridad para evitar valores infinitos
  # paso los infinitos a NULOS
  infinitos <- lapply(
    names(dataset),
    function(.name) dataset[, sum(is.infinite(get(.name)))]
  )

  infinitos_qty <- sum(unlist(infinitos))
  if (infinitos_qty > 0) {
    cat(
      "ATENCION, hay", infinitos_qty,
      "valores infinitos en tu dataset. Seran pasados a NA\n"
    )
    dataset[mapply(is.infinite, dataset)] <<- NA
  }


  # valvula de seguridad para evitar valores NaN  que es 0/0
  # paso los NaN a 0 , decision polemica si las hay
  # se invita a asignar un valor razonable segun la semantica del campo creado
  nans <- lapply(
    names(dataset),
    function(.name) dataset[, sum(is.nan(get(.name)))]
  )

  nans_qty <- sum(unlist(nans))
  if (nans_qty > 0) {
    cat(
      "ATENCION, hay", nans_qty,
      "valores NaN 0/0 en tu dataset. Seran pasados arbitrariamente a 0\n"
    )

    cat("Si no te gusta la decision, modifica a gusto el programa!\n\n")
    dataset[mapply(is.nan, dataset)] <<- 0
  }
}
#------------------------------------------------------------------------------
# deflaciona por IPC
# momento 1.0  31-dic-2020 a las 23:59

drift_deflacion <- function(campos_monetarios) {
  vfoto_mes <- c(
    201901, 201902, 201903, 201904, 201905, 201906,
    201907, 201908, 201909, 201910, 201911, 201912,
    202001, 202002, 202003, 202004, 202005, 202006,
    202007, 202008, 202009, 202010, 202011, 202012,
    202101, 202102, 202103, 202104, 202105, 202106,
    202107, 202108, 202109
  )

  vIPC <- c(
    1.9903030878, 1.9174403544, 1.8296186587,
    1.7728862972, 1.7212488323, 1.6776304408,
    1.6431248196, 1.5814483345, 1.4947526791,
    1.4484037589, 1.3913580777, 1.3404220402,
    1.3154288912, 1.2921698342, 1.2472681797,
    1.2300475145, 1.2118694724, 1.1881073259,
    1.1693969743, 1.1375456949, 1.1065619600,
    1.0681100000, 1.0370000000, 1.0000000000,
    0.9680542110, 0.9344152616, 0.8882274350,
    0.8532444140, 0.8251880213, 0.8003763543,
    0.7763107219, 0.7566381305, 0.7289384687
  )

  tb_IPC <- data.table(
    "foto_mes" = vfoto_mes,
    "IPC" = vIPC
  )

  dataset[tb_IPC,
    on = c("foto_mes"),
    (campos_monetarios) := .SD * i.IPC,
    .SDcols = campos_monetarios
  ]
}

#------------------------------------------------------------------------------

drift_rank_simple <- function(campos_drift) {
  for (campo in campos_drift)
  {
    cat(campo, " ")
    dataset[, paste0(campo, "_rank") :=
      (frank(get(campo), ties.method = "random") - 1) / (.N - 1), by = foto_mes]
    dataset[, (campo) := NULL]
  }
}
#------------------------------------------------------------------------------
# El cero se transforma en cero
# los positivos se rankean por su lado
# los negativos se rankean por su lado

drift_rank_cero_fijo <- function(campos_drift) {
  for (campo in campos_drift)
  {
    cat(campo, " ")
    dataset[get(campo) == 0, paste0(campo, "_rank") := 0]
    dataset[get(campo) > 0, paste0(campo, "_rank") :=
      frank(get(campo), ties.method = "random") / .N, by = foto_mes]

    dataset[get(campo) < 0, paste0(campo, "_rank") :=
      -frank(-get(campo), ties.method = "random") / .N, by = foto_mes]
    dataset[, (campo) := NULL]
  }
}
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
# Aqui comienza el programa
OUTPUT$PARAM <- PARAM
OUTPUT$time$start <- format(Sys.time(), "%Y%m%d %H%M%S")

setwd(PARAM$home)

# cargo el dataset donde voy a entrenar
# esta en la carpeta del exp_input y siempre se llama  dataset.csv.gz
dataset_input <- paste0("./exp/", PARAM$exp_input, "/dataset.csv.gz")
dataset <- fread(dataset_input)

# creo la carpeta donde va el experimento
dir.create(paste0("./exp/", PARAM$experimento, "/"), showWarnings = FALSE)
# Establezco el Working Directory DEL EXPERIMENTO
setwd(paste0("./exp/", PARAM$experimento, "/"))

GrabarOutput()
write_yaml(PARAM, file = "parametros.yml") # escribo parametros utilizados

# primero agrego las variables manuales
if (PARAM$variables_intrames) AgregarVariables_IntraMes(dataset)

# ordeno de esta forma por el ranking
setorder(dataset, foto_mes, numero_de_cliente)

# por como armé los nombres de campos,
#  estos son los campos que expresan variables monetarias
campos_monetarios <- colnames(dataset)
campos_monetarios <- campos_monetarios[campos_monetarios %like%
  "^(m|Visa_m|Master_m|vm_m)"]

# aqui aplico un metodo para atacar el data drifting
# hay que probar experimentalmente cual funciona mejor
switch(PARAM$metodo,
  "ninguno"        = cat("No hay correccion del data drifting"),
  "rank_simple"    = drift_rank_simple(campos_monetarios),
  "rank_cero_fijo" = drift_rank_cero_fijo(campos_monetarios),
  "deflacion"      = drift_deflacion(campos_monetarios)
)



fwrite(dataset,
  file = "dataset.csv.gz",
  logical01 = TRUE,
  sep = ","
)

#------------------------------------------------------------------------------

# guardo los campos que tiene el dataset
tb_campos <- as.data.table(list(
  "pos" = 1:ncol(dataset),
  "campo" = names(sapply(dataset, class)),
  "tipo" = sapply(dataset, class),
  "nulos" = sapply(dataset, function(x) {
    sum(is.na(x))
  }),
  "ceros" = sapply(dataset, function(x) {
    sum(x == 0, na.rm = TRUE)
  })
))

fwrite(tb_campos,
  file = "dataset.campos.txt",
  sep = "\t"
)

#------------------------------------------------------------------------------
OUTPUT$dataset$ncol <- ncol(dataset)
OUTPUT$dataset$nrow <- nrow(dataset)
OUTPUT$time$end <- format(Sys.time(), "%Y%m%d %H%M%S")
GrabarOutput()

# dejo la marca final
cat(format(Sys.time(), "%Y%m%d %H%M%S"), "\n",
  file = "zRend.txt",
  append = TRUE
)
