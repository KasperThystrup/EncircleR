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
    div(
      id = "mapping",
      shinydashboard::box(
        title = "Mapping statistics",
        plotOutput(outputId = ns("alignPercent")),
        "The linear mapping statistics of each sample shown in percentages",
        
        plotOutput(ns("SJvsLibSize")),
        "Splice junctions compared to Total Library size, the dashed line denotes the linear ratio, calculated with a linar model",
        
        plotOutput(ns("readStats"))
      )
    )
  )
}
    
#' mappingPlots Server Function
#'
#' @noRd 
mod_mappingPlots_server <- function(input, output, session, r){
  ns <- session$ns
  
  observeEvent(eventExpr = r$filt_ready, handlerExpr = {
    
    if (r$circ_ready) {
      output$alignPercent <- renderPlot(plotAlignmentPecentages(r$object))
      
      output$SJvsLibSize <- renderPlot(plotSpliceLibSize(r$object))
      
      output$readStats <- renderPlot(plotReadStats(r$object))
    }
  })
}
    
## To be copied in the UI
# mod_mappingPlots_ui("mappingPlots_ui_1")
    
## To be copied in the server
# callModule(mod_mappingPlots_server, "mappingPlots_ui_1")
 
