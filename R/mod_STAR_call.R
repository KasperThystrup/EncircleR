#' STAR_call UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shinyjs hide show
mod_STAR_call_ui <- function(id){
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::div(
      id = ns("star_setup"),
        
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

      shiny::numericInput(
        inputId = ns("ram_lim"),
        label = "RAM limit dedicated for BAM sorting",
        value = 5e9, min = 1e6
      ),

      shiny::numericInput(
        inputId = ns("min_seq"),
        label = "Minimal segment length on chimeric reads",
        value = 20, min = 5
      ),
      
      shiny::sliderInput(
        inputId = ns("threads"),
        label = "Determine number of cores",
        min = 0,
        max = max_cores,
        value = 4,
        step = 1
      ),

      shiny::actionButton(
        inputId = ns("star_call"),
        label = "Begin alignment",
        icon = shiny::icon("star") # align-center ## microscope
      ),
      
      shiny::checkboxInput(
        inputId = ns("star_overwrite"),
        label = "Overwrite alignment files",
        value = FALSE
      )
    )
  )
}

#' STAR_call Server Function
#'
#' @noRd
mod_STAR_call_server <- function(input, output, session, r){
  ns <- session$ns
  
  shinyjs::hide(id = "star_setup")
  shiny::observeEvent(eventExpr = r$fastp_ready, handlerExpr = {
    shinyjs::hide(id = "star_setup")
    if (r$fastp_ready)
      shinyjs::show(id = "star_setup")
  })
  
  shinyjs::hideElement(id = "star_call")
  shiny::observeEvent(eventExpr = input$threads, handlerExpr = {
    shinyjs::hideElement(id = "star_call")
    if (input$threads > 0)
      shinyjs::showElement(id = "star_call")
  })

  shiny::observeEvent(eventExpr = input$star_call, handlerExpr = {
    r$star_ready <- FALSE
    logger::log_debug("Generating sample data table")

    sample <- dplyr::pull(r$meta, Sample) %>%
      unique
    
    
    
    if (input$star_overwrite | any(!dir.exists(file.path(r$smpl_dir, sample, "STAR")))) {
    # Progress counter

      shiny::withProgress(value = 0, min = 0, max = length(sample) + 2, message = "Initiating STAR alignment", expr = {
      Sys.sleep(0.75)
        shiny::incProgress(
        amount = 0.15, session = session,
        message = "Loading genome index"
      )

        lapply(sample, function(smpl){
  
          sample_subset <- subset(r$meta, Sample == smpl)
          shiny::incProgress(amount = 1, message = paste("Aligning sample:", smpl))
          callSTAR(
            star = input$star, genome_dir = r$star_dir,
            threads = input$threads, sample = smpl, meta = r$meta,
            paired = r$paired, out_dir = file.path(r$smpl_dir, "STAR"),
            RAM_limit = input$ram_lim, chim_segMin = input$min_seq,
            compression = "gz"
          )
        })

    })
    }
    r$star_ready <- TRUE
    
  })
}

### To be copied in the UI
## mod_STAR_call_ui("STAR_call_ui_1")

### To be copied in the server
## callModule(mod_STAR_call_server, "STAR_call_ui_1")

