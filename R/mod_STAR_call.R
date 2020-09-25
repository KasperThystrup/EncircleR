#' STAR_call UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_STAR_call_ui <- function(id){
  ns <- NS(id)
  tagList(
    div(
      id = ns("star_setup"),
        
      textInput(
        inputId = ns("star"),
        label = "Locate binary star file or provide default system call",
        value = star_default
      ),

      numericInput(
        inputId = ns("ram_lim"),
        label = "RAM limit dedicated for BAM sorting",
        value = 5e9, min = 1e6
      ),

      numericInput(
        inputId = ns("min_seq"),
        label = "Minimal segment length on chimeric reads",
        value = 20, min = 5
      ),
      
      sliderInput(
        inputId = ns("threads"),
        label = "Determine number of cores",
        min = 0,
        max = max_cores,
        value = 0,
        step = 1
      ),

      actionButton(
        inputId = ns("star_call"),
        label = "Begin alignment",
        icon = icon("star") # align-center ## microscope
      ),
      
      checkboxInput(
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
  
  hide(id = "star_setup")
  observeEvent(eventExpr = r$fastp_ready, handlerExpr = {
    hide(id = "star_setup")
    if (r$fastp_ready)
      show(id = "star_setup")
  })
  
  shinyjs::hideElement(id = "star_call")
  observeEvent(eventExpr = input$threads, handlerExpr = {
    shinyjs::hideElement(id = "star_call")
    if (input$threads > 0)
      shinyjs::showElement(id = "star_call")
  })

  observeEvent(eventExpr = input$star_call, handlerExpr = {
    r$star_ready <- FALSE
    logger::log_debug("Generating sample data table")

    sample <- dplyr::pull(r$meta, Sample) %>%
      unique
    
    r$star_ready <- FALSE
    if (input$star_overwrite | any(!dir.exists(file.path(r$smpl_dir, sample)))) {
    # Progress counter

    withProgress(value = 0, min = 0, max = length(sample) + 2, message = "Initiating STAR alignment", expr = {
      Sys.sleep(0.75)
      incProgress(
        amount = 0.15, session = session,
        message = "Loading genome index"
      )

      
      # incProgress(amount = 1, message = "Attaching Genome into memory")
      # attachSTARGenome(star = input$star, genome_dir = r$star_dir)   ### Not sure how to set up with bam sorting limit


        lapply(sample, function(smpl){
  
          sample_subset <- subset(r$meta, Sample == smpl)
          incProgress(amount = 1, message = paste("Aligning sample:", smpl))
          callSTAR(
            star = input$star, genome_dir = r$star_dir,
            threads = input$threads, sample = smpl, meta = r$meta,
            paired = r$paired, out_dir = r$smpl_dir,
            RAM_limit = input$ram_lim, chim_segMin = input$min_seq,
            compression = "gz"
          )
        })

      # incProgress(amount = 1, message = "Dettaching genome and cleaning up")
      # dettachSTARGenome(star = input$star, genome_dir = r$star_dir)
    })
    }
    r$star_ready <- TRUE
    
  })
}

### To be copied in the UI
## mod_STAR_call_ui("STAR_call_ui_1")

### To be copied in the server
## callModule(mod_STAR_call_server, "STAR_call_ui_1")

