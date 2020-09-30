#' circTable UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_circTable_ui <- function(id){
  ns <- NS(id)
  tagList(
    
 
  )
}
    
#' circTable Server Function
#'
#' @noRd 
mod_circTable_server <- function(input, output, session, r){
  ns <- session$ns
  
}
    
## To be copied in the UI
# mod_circTable_ui("circTable_ui_1")
    
## To be copied in the server
# callModule(mod_circTable_server, "circTable_ui_1")
 
