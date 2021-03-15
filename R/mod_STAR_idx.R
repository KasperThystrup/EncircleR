#' STAR_idx UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shinyjs hide show
mod_STAR_idx_ui <- function(id){
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::div(
      id = ns("star_idx"),
      
      shiny::textInput(
        inputId = ns("star"),
        label = "Locate binary star file or provide default system call",
        value = "~/miniconda3/bin/STAR", 
        placeholder = "Provide command or path for STAR binary"
      ),
      shiny::helpText(
        "Usually the binary file for STAR can be found in the `bin/Linux_x86_64` or `bin/MacOs_x86_64` instalation folder eg:",
        "/home/user/aligners/STAR/bin/Linux_x86_64/STAR"
      ),
  
      shiny::sliderInput(
        inputId = ns("threads"),
        label = "Determine number of cores",
        min = 1,
        max = max_cores,
        value = 1,
        step = 1
      ),
  
      shiny::numericInput(
        inputId = ns("read_length"),
        label = "Read length",
        min = 0,
        value = 100
      ),
  
      shiny::actionButton(
        inputId = ns("idx"),
        label = "Prepare STAR index",
        icon = shiny::icon("dolly")
      ),
      
      shiny::checkboxInput(
        inputId = ns("idx_overwrite"),
        label = "Overwrite existing STAR index files",
        value = FALSE
      ),
      
      shiny::checkboxInput(
        inputId = ns("idx_cleanup"),
        label = "Clean up Fasta and GTF files",
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
  
  shinyjs::hide(id = "star_idx")
  shiny::observeEvent(eventExpr = input$threads, handlerExpr = {
    shinyjs::showElement(id = "idx")
    if (input$threads == 0)
      shinyjs::hideElement(id = "idx")
  })
  
  shiny::observeEvent(eventExpr = r$annot_ready, handlerExpr = {
    shinyjs::hide(id = "star_idx")
    if (r$annot_ready){
      shinyjs::show(id = "star_idx")
    }
  })
  
  

  shiny::observeEvent(eventExpr = input$idx, handlerExpr = {
    shiny::withProgress(
      value = 0, session = session, message = "Loading STAR index", expr = {
        Sys.sleep(0.75)
        r$idx_ready <- FALSE
        r$star <- input$star

        logger::log_debug("Defining genome directory")
        r$star_dir <- file.path(r$genome_dir, "STAR")

        logger::log_debug("Determining whether index folder exists")
        if (!dir.exists(r$star_dir) | input$idx_overwrite) {
  
          shiny::incProgress(
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
            threads = input$threads,
            read_length = 100
          )
          
          if (input$idx_cleanup) {
            cmd_rm_fa <- paste("rm", r$fa_fn)
            system(cmd_rm_fa)
            
            cmd_rm_gtf <- paste("rm", r$gtf_fn)
            system(cmd_rm_gtf)
          }
        }
        
        shiny::incProgress(
          amount = 0.75, session = session,
          message = "Updating available reference genomes"
        )
        
        available_references <- listReferences(cache_dir = r$cache_dir)
        shiny::updateSelectInput(
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

