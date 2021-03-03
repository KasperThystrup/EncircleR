#' mappingPlots UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
mod_mappingPlots_ui <- function(id){
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::div(
      id = "mapping",
      
      shiny::column(
        width = 6,
        shiny::plotOutput(outputId = ns("alignPercent")),
        "The linear mapping statistics of each sample shown in percentages",
        
        shiny::plotOutput(ns("SJvsLibSize")),
        "Splice junctions compared to Total Library size, the dashed line denotes the linear ratio, calculated with a linar model",
        
      ), 
      
      shiny::column(
        width = 6,
        
        shiny::plotOutput(ns("readStats")),
        "Input chimeric read statistics"#,
        
        # shiny::plotOutput(outputId = ns("filtration")),
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
  
  shiny::observeEvent(eventExpr = r$circ_ready, handlerExpr = {
    
    if (r$circ_ready) {
      output$alignPercent <- shiny::renderPlot(plotAlignmentPecentages(r$object))

      output$SJvsLibSize <- shiny::renderPlot(plotSpliceLibSize(r$object))
      
      output$readStats <- shiny::renderPlot(plotReadStats(r$object))
      
      # output$filtration <- shiny::renderPlot(plotFiltrationStats(r$object))
    }
  })
}
    
## To be copied in the UI
# mod_mappingPlots_ui("mappingPlots_ui_1")
    
## To be copied in the server
# callModule(mod_mappingPlots_server, "mappingPlots_ui_1")
 
