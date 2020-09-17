#' getAnnotation UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
#' @import shinyjs
#' @import dplyr
mod_getAnnotation_ui <- function(id){
  ns <- NS(id)
  tagList(
    shiny::div(
      id = ns("ref"),

      selectInput(
        inputId = ns("org"),
        label = "Please select a host organism",
        choices = c(
          "Select an organism" = NA,
          supported_organisms
        )
      ),
      
      sliderInput(
        inputId = ns("rel"),
        label = "Please select an Ensembl release version", 
        min = -1,
        max = 1,
        value = 0,
        step = 1
      ),
      
      actionButton(
        inputId = ns("step"),
        label = "Download reference files",
        icon = icon("cart-arrow-down")
      )
    )
  )
}
    
#' getAnnotation Server Function
#'
#' @noRd 
mod_getAnnotation_server <- function(input, output, session, r){
  ns <- session$ns
  
  hide(id = "ref")
  shinyjs::hideElement(id = "rel")
  shinyjs::hideElement(id = "step")
  observeEvent(eventExpr = r$select_ready, handlerExpr = {
    hide(id = "ref")
    shinyjs::hideElement(id = "rel")
    withProgress(
      value = 0.5, message = "Determining whether reference genome is ready",
      expr = {
        if (r$select_ready) {
          
          incProgress(amount = 0.25, message = "Fetching information from AnnotationHub")
          logger::log_debug("Fetching annotation object")
          r$ah <- AnnotationHub::AnnotationHub()
          incProgress(amount = 0.25, message = "Information fetched")
          show(id = "ref")
          Sys.sleep(0.75)
        }
      }
    )
  })
  
  
  observeEvent(eventExpr = input$org, handlerExpr = {
    shinyjs::hideElement(id = "step")

    if (input$org %in% supported_organisms) {
      logger::log_info("Querying selected organism")
      shiny::withProgress(expr = {
        incProgress(amount = 0.25, message = "Determining available EnsDb releases") 
        
        logger::log_debug("Listing available resources")
        queries <- availableEnsemblReleases(ahub = r$ah, organism = input$org)
        logger::log_debug("Determining extremities")
        ens_extremes <- EnsDbExtremities(queries)
        
        incProgress(amount = 0.25, message = "Determining available reference releases") 
        logger::log_debug("Extracting reference metadata")
        meta <- extractReferenceMeta(ahub = r$ah, organism = input$org, release = NULL)
        logger::log_debug("Defining release extermities of reference and annotation objects")
        ref_extremes <- referenceExtremities(meta = meta)
        logger::log_debug("Selecting common extremities.")
        extremes <- determineExtremities(ens_extremes, ref_extremes)
        
        incProgress(amount = 0.25, message = "Updating available releases")
        
        updateSliderInput(
          session = session, inputId = "rel",
          min = extremes[1], max = extremes[2], value = extremes[2]
        )
        
        
        
        Sys.sleep(0.25)
      }, value = 0, message = "Fetching Annotation resource Ensembl releases")
      
      logger::log_debug("Showing elements after query")
      shinyjs::showElement(id = "org")
      shinyjs::showElement(id = "rel")
      shinyjs::showElement(id = "step")
      
    }
  })
  
  
  # Select organisms
  observeEvent(eventExpr = input$step, handlerExpr = {
    r$annot_ready <- FALSE
    
    shinyjs::hideElement(id = "step")
    shiny::withProgress(expr = {
      Sys.sleep(0.75)
      logger::log_debug("Recording input and hiding inputs")
      build.idx <- match(input$org, names(supported_builds))
      build <- supported_builds[build.idx]
      r$build <- build
      r$org <- input$org
      r$rel <- input$rel
      
      incProgress(amount = 0.25, message = "Looking up reference URLs")
      
      logger::log_debug("Extracting reference metadata")
      meta <- extractReferenceMeta(ahub = r$ah, organism = input$org, release = input$rel)
      
      logger::log_debug("Determining target URLs")
      urls <- getDownloadLinks(meta = meta, organism = input$org, build = build, release = input$rel)
      
      r$genome_dir <- file.path("~/.EncircleR/Genome", paste("release", input$rel, sep = "-"), input$org)
      
      incProgress(amount = 0.25, message = "Downloading and unzipping reference annotation")
      r$gtf_fn <- downloadFile(url = urls$gtf, out_dir = r$genome_dir)
      
      incProgress(amount = 0.25, message = "Downloading and unzipping reference genome")
      r$fa_fn <- downloadFile(url = urls$fa, out_dir = r$genome_dir)
      
      incProgress(
        amount = 0.25,
        message = paste(names(input$org), "Fasta and GTF file downloaded!")
      )
      
      Sys.sleep(0.75)
      
      r$annot_ready <- TRUE
      
      shinyjs::showElement(id = "step")
    }, value = 0, message = "Choices locked in")
  })
}
    
## To be copied in the UI
## mod_getAnnotation_ui("getAnnotation_ui_1")
    
## To be copied in the server
## callModule(mod_getAnnotation_server, "getAnnotation_ui_1")
 
