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
      
      column(
        width = 6,
        plotOutput(outputId = ns("alignPercent")),
        "The linear mapping statistics of each sample shown in percentages",
        
        plotOutput(ns("SJvsLibSize")),
        "Splice junctions compared to Total Library size, the dashed line denotes the linear ratio, calculated with a linar model",
        
      ), 
      
      column(
        width = 6,
        
        plotOutput(ns("readStats")),
        "More statistics"#,
        
        # plotOutput(outputId = ns("filtration")),
        # "Statistics on chimeric read filtration"
      )
    )
  )
}
    
#' mappingPlots Server Function
#'
#' @noRd 
mod_mappingPlots_server <- function(input, output, session, r){
  ns <- session$ns
  
  observeEvent(eventExpr = r$circ_ready, handlerExpr = {
    
    if (r$circ_ready) {
      output$alignPercent <- renderPlot(plotAlignmentPecentages(r$object))

      output$SJvsLibSize <- renderPlot(plotSpliceLibSize(r$object))
      
      output$readStats <- renderPlot(plotReadStats(r$object))
      
      # output$filtration <- renderPlot(plotFiltrationStats(r$object))
    }
  })
}
    
## To be copied in the UI
# mod_mappingPlots_ui("mappingPlots_ui_1")
    
## To be copied in the server
# callModule(mod_mappingPlots_server, "mappingPlots_ui_1")
 
