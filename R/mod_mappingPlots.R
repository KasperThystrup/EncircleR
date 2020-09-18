#' mappingPlots UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_mappingPlots_ui <- function(id){
  ns <- NS(id)
  tagList(
    shinydashboard::box(
      title = "Mapping statistics",
      plotOutput(outputId = ns("alignPercent")),
      actionButton(inputId = ns("dl_alignPerc.pdf"), label = "pdf", icon = icon("download")),
      actionButton(inputId = ns("dl_alignPerc.tsv"), label = "tsv", icon = icon("download")),
      actionButton(inputId = ns("dl_alignPerc.pdf"), label = "pdf", icon = icon("download"))
    )
  )
}
    
#' mappingPlots Server Function
#'
#' @noRd 
mod_mappingPlots_server <- function(input, output, session, r){
  ns <- session$ns
  
  output$alignPercent <- renderPlot(plotAlignmentPecentages(r$object))
  
 
}
    
## To be copied in the UI
# mod_mappingPlots_ui("mappingPlots_ui_1")
    
## To be copied in the server
# callModule(mod_mappingPlots_server, "mappingPlots_ui_1")
 
