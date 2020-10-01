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
      
      actionButton(inputId = ns("GO"), label = "Generate circRNA table"),
      DT::DTOutput(outputId = ns("circRNAs"))
    )
  )
}
    
#' circTable Server Function
#'
#' @noRd 
#' 
#' @importFrom DT datatable
#' @importFrom readr read_tsv
mod_circTable_server <- function(input, output, session, r){
  ns <- session$ns
  
  observeEvent(eventExpr = input$GO, handlerExpr = {
    withProgress(value = 0, message = "Fetching circBase resources", expr = {
      circBase_link <- switch (r$org,
        "Homo_sapiens" = "http://www.circbase.org/download/hsa_hg19_circRNA.txt",
        "Mus_musculus" = "http://www.circbase.org/download/mmu_mm9_circRNA.txt"
      )
      circbase_colums <- c(
        c("chrom", "start", "end", "strand", "circRNAID", "genomicLength",
          "splicedSeqLength", "samples", "repeats", "annotation",
          "bestTranscript", "symbol", "study"
        )
        
      )
      
      circbase <- readr::read_tsv(circBase_link, col_names = circbase_colums, skip = 1L)
      
      output$circRNAs <- DT::renderDT(DT::datatable(makeTables(object = r$object, ah = r$ahdb, circbase), escape = FALSE))
      
      
    })
  })
  
}
    
## To be copied in the UI
# mod_circTable_ui("circTable_ui_1")
    
## To be copied in the server
# callModule(mod_circTable_server, "circTable_ui_1")
 
