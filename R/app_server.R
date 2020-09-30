#' The application server-side
#' 
#' @param input,output,session Internal parameters for {shiny}. 
#'     DO NOT REMOVE.
#' @import shiny
#' @import logger
#' @noRd
app_server <- function( input, output, session ) {
  # List the first level callModules here
  # logger::log_shiny_input_changes(input)
  r <- reactiveValues()
  callModule(mod_importMetadata_server, "importMetadata_ui_1", r)
  callModule(mod_setupExperiment_server, "setupExperiment_ui_1", r)
  callModule(mod_selectReferences_server, "selectReferences_ui_1", r)
  callModule(mod_getAnnotation_server, "getAnnotation_ui_1", r)
  callModule(mod_STAR_idx_server, "STAR_idx_ui_1", r)
  callModule(mod_callFastp_server, "callFastp_ui_1", r)
  callModule(mod_STAR_call_server, "STAR_call_ui_1", r)
  callModule(mod_deplyCirculaR_server, "deplyCirculaR_ui_1", r)
  callModule(mod_applyFilters_server, "applyFilters_ui_1", r)
  callModule(mod_mappingPlots_server, "mappingPlots_ui_1", r)
  callModule(mod_circTable_server, "circTable_ui_1", r)
}
