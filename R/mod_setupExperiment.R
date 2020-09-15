#' setupExperiment UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @import shiny
#' @importfrom shinydashboard box
mod_setupExperiment_ui <- function(id){
  ns <- NS(id)
  tagList(
    div(
      id = ns("exp_setup"),
      shinydashboard::box(
        title = "Experimental directory",
      
        textInput(
          inputId = ns("exp_dir"),
          label = "Please enter the desired output path of the experimental directory",
          placeholder = "Enter the full path to the top folder",
          value = "/home/kathka/Projects/Conceptual/fastR/Experiment"
        ),
  
        actionButton(
          inputId = ns("run"),
          label = "Set up experiment with samples",
          icon = icon("search")
        ),
        helpText(paste(
          "This initiates sample import either by copying or moving fastq files.",
          "Next fastq files are automatically renamed according to sample names",
          "and read mate data from the metadata file."
        )),
  
        checkboxInput(
          inputId = ns("keep"),
          label = "Copy fastq files to experimental dir (Fastq files are moved instead if disabled)",
          value = TRUE
        ),
        
        helpText(paste(
          "WARNING: Do not uncheck the option, if you have no backup of your fast files.",
          "In this case, copy your files instead!"
        ))
      )
    )
  )
}

#' setupExperiment Server Function
#'
#' @noRd
mod_setupExperiment_server <- function(input, output, session, r){
  ns <- session$ns
  shinyjs::hide(id = "exp_setup")
  
  observeEvent(eventExpr = r$ready, handlerExpr = {
    if (r$ready)
      shinyjs::show(id = "exp_setup")
  })

  observeEvent(eventExpr = input$run, handlerExpr = {
    shiny::withProgress(value = 0, message = "Preparaing sample files", expr = {
      r$show_settings <- FALSE

      incProgress(amount = 0.25, message = "Preparing experimental directory")
      # Check on experimental directory
      cmd_makedir <- paste("mkdir -p", input$exp_dir)

      system(cmd_makedir)
      r$exp_dir <- input$exp_dir

      incProgress(
        amount = 0.5,
        message = "Setting up samples in Experimental folder (may take some time)"
      )
      logger::log_info("Relocating and updating file names")
      r$meta <- reassignSampleFiles(exp_dir = input$exp_dir, meta = r$meta, copy = input$keep)
      r$show_settings <- TRUE
    })
  })
}

# ## To be copied in the UI
# # mod_setupExperiment_ui("setupExperiment_ui_1")
#
# ## To be copied in the server
# # callModule(mod_setupExperiment_server, "setupExperiment_ui_1")

