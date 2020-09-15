#' The application server-side
#' 
#' @param input,output,session Internal parameters for {shiny}. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function( input, output, session ) {
  # List the first level callModules here
  r <- reactiveValues()
  callModule(mod_getAnnotation_server, "getAnnotation_ui_1", r)
  callModule(mod_importMetadata_server, "importMetadata_ui_1", r)
  callModule(mod_setupExperiment_server, "importSamples_ui_1", r)
  callModule(mod_callFastp_server, "callFastp_ui_1", r)
  callModule(mod_STAR_idx_server, "STAR_idx_ui_1", r)
  callModule(mod_STAR_call_server, "STAR_call_ui_1", r)
}
