#' setupExperiment UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shinyjs hide show
mod_setupExperiment_ui <- function(id){
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::div(
      id = ns("exp"),
      shiny::textInput(
        inputId = ns("exp_dir"),
        label = "Please enter the desired output path of the experimental directory",
        placeholder = "Enter the full path to the top folder"
      ),
  
      shiny::actionButton(
        inputId = ns("exp_start"),
        label = "Setup experiment",
        icon = shiny::icon("truck-loading")
      ),
      shiny::helpText(paste(
        "This initiates sample import either by copying or moving fastq files.",
        "Next fastq files are automatically renamed according to sample names",
        "and read mate data from the metadata file."
      )),
  
      shiny::checkboxInput(
        inputId = ns("keep"),
        label = "Copy fastq files to experimental dir (Fastq files are moved instead if disabled)",
        value = TRUE
      ),
      
      shiny::helpText(paste(
        "WARNING: Do not uncheck the option, if you have no backup of your fast files.",
        "In this case, copy your files instead!"
      ))
    )
  )
}

#' setupExperiment Server Function
#'
#' @noRd
mod_setupExperiment_server <- function(input, output, session, r){
  ns <- session$ns
  
  shinyjs::hide(id = "exp")
  shiny::observeEvent(eventExpr = r$meta_ready, handlerExpr = {
    shinyjs::hide(id = "exp")
    if (r$meta_ready)
      shinyjs::show(id = "exp")
  })
  
  shiny::observeEvent(eventExpr = input$exp_start, handlerExpr = {
    shiny::withProgress(value = 0, message = "Preparaing sample files", expr = {
      r$exp_ready <- FALSE

      shiny::incProgress(amount = 0.25, message = "Preparing experimental directory")
      
      # Check on experimental directory
      r$exp_dir <- input$exp_dir
      r$smpl_dir <- file.path(input$exp_dir, "Samples")
      
      
      cmd_makedir <- paste("mkdir -p", r$smpl_dir)

      system(cmd_makedir)

      shiny::incProgress(
        amount = 0.5,
        message = "Setting up samples in Experimental folder (may take some time)"
      )
      logger::log_info("Relocating and updating file names")
      r$meta <- reassignSampleFiles(exp_dir = input$exp_dir, meta = r$meta, copy = input$keep)
      r$exp_ready <- TRUE
    })
  })
}

# ## To be copied in the UI
# # mod_setupExperiment_ui("setupExperiment_ui_1")
#
# ## To be copied in the server
# # callModule(mod_setupExperiment_server, "setupExperiment_ui_1")

