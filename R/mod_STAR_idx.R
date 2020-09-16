#' STAR_idx UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @import shinydashboard
mod_STAR_idx_ui <- function(id){
  ns <- NS(id)
  tagList(
    div(
      id = ns("star_idx"),
      
      textInput(
        inputId = ns("star"),
        label = "Locate binary star file or provide default system call",
        value = "star-seq-alignment"
      ),
  
      sliderInput(
        inputId = ns("threads"),
        label = "Determine number of cores",
        min = 0,
        max = max_cores,
        value = 0,
        step = 1
      ),
  
      numericInput(
        inputId = ns("read_length"),
        label = "Read length",
        min = 0,
        value = 100
      ),
  
      actionButton(
        inputId = ns("idx"),
        label = "Prepare STAR index",
        icon = icon("dolly")
      ),
      
      checkboxInput(
        inputId = ns("idx_overwrite"),
        label = "Overwrite existing fastp files",
        value = FALSE
      )
    )
  )
}

#' STAR_idx Server Function
#'
#' @noRd
mod_STAR_idx_server <- function(input, output, session, r){
  ns <- session$ns
  
  hide(id = "star_idx")
  # shinyjs::hideElement("star")
  # shinyjs::hideElement("threads")
  # shinyjs::hideElement("read_length")
  # shinyjs::hideElement("idx")
  
  observeEvent(eventExpr = input$threads, handlerExpr = {
    shinyjs::showElement(id = "idx")
    if (input$threads == 0)
      shinyjs::hideElement(id = "idx")
  })
  
  observeEvent(eventExpr = r$annot_ready, handlerExpr = {
    hide(id = "star_idx")
    # shinyjs::hideElement("star")
    # shinyjs::hideElement("threads")
    # shinyjs::hideElement("read_length")
    # shinyjs::hideElement("idx")
    if (r$annot_ready){
      show(id = "star_idx")
      # shinyjs::hideElement("star")
      # shinyjs::showElement("star_idx")
      # shinyjs::showElement("threads")
      # shinyjs::showElement("read_length")
    }
  })
  
  

  observeEvent(eventExpr = input$idx, handlerExpr = {
    withProgress(
      value = 0, session = session, message = "Loading STAR index", expr = {
        Sys.sleep(0.75)
        r$idx_ready <- FALSE
        r$star <- input$star

        logger::log_debug("Defining genome directory")
        r$star_dir <- file.path(r$genome_dir, "STAR")

        logger::log_debug("Determining whether index folder exists")
        browser()
        if (!dir.exists(r$star_dir) | input$idx_overwrite) {
  
          incProgress(
            amount = 0.15, session = session,
            message = "Generating STAR index - This will take a while!"
          )
          # Generate STAR index generation command
          logger::log_info("Generating genome index")
  
          generateSTARidx(
            star = input$star,
            out_dir = r$star_dir,
            fa_file = r$fa_fn,
            gtf_file = r$gtf_fn,
            threads = r$threads,
            read_length = 100
          )
        }
        
        incProgress(
          amount = 0.75, session = session,
          message = "Updating available reference genomes"
        )
        
        available_references <- listReferences(r$cache_dir)
        updateSelectInput(
          inputId = "ref_select",
          choices = c("Please select a reference genome" = NA, available_references),
          session = session
        )
        
        r$idx_ready <- TRUE
        r$annot_ready <- FALSE
        r$select_ready <- FALSE
        
    })
  })
}

### To be copied in the UI
## mod_STAR_idx_ui("STAR_idx_ui_1")

### To be copied in the server
## callModule(mod_STAR_idx_server, "STAR_idx_ui_1")

