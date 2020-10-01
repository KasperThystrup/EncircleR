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
    div(
      id = ns("circTables"),
      
      actionButton(inputId = ns("GO"), label = "label"),
      DT::DTOutput(outputId = ns("circRNAs"))
    )
  )
}
    
#' circTable Server Function
#'
#' @noRd 
#' 
#' @importFrom DT datatable
mod_circTable_server <- function(input, output, session, r){
  ns <- session$ns
  
  observeEvent(eventExpr = input$GO, handlerExpr = {
    
    output$circRNAs <- DT::renderDT(DT::datatable(makeTables(object = r$object, ah = r$ahdb), escape = FALSE))
  })
  
}
    
## To be copied in the UI
# mod_circTable_ui("circTable_ui_1")
    
## To be copied in the server
# callModule(mod_circTable_server, "circTable_ui_1")
 
