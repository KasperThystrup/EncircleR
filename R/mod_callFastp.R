#' callFastp UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_callFastp_ui <- function(id){
  ns <- NS(id)
  tagList(

    div(
      id = ns("fastp_setup"),

      shinydashboard::box(
        title = "Read trimming and quality check",
        textInput(
          inputId = ns("fastp"),
          label = "Please enter the system command or path to program",
          placeholder = "Please enter system command or full path to fastp binary file",
          value = "/home/kathka/miniconda3/bin/fastp"
        ),

        numericInput(
          inputId = ns("threads"),
          label = "Number of threads to run",
          value = 1,
          step = 1
        ),

        actionButton(
          inputId = ns("run_fastp"),
          label = "Begin read QC and Trimming",
          icon = icon("sliders-h")
        ),

        checkboxInput(
          inputId = ns("overwrite"),
          label = "Overwrite existing trimmed reads",
          value = FALSE
        ),
        
        shinydashboard::box(

          title = "Advanced settings",
          collapsible = TRUE,
          collapsed = TRUE,
          numericInput(
            inputId = ns("trim_front"),
            label = "Bases trimmed at the 5' tail",
            value = 7,  ## should be 0 !!
            min = 0,
            step = 1
          ),
  
          checkboxInput(
            inputId = ns("cut_front"),
            label = "Drop low quality bases from the 5' tail",
            value = TRUE  ## should be FALSE !!
          ),
  
          numericInput(
            inputId = ns("trim_tail"),
            label = "Bases trimmed at the 3' tail",
            value = 7,
            min = 0,  ## should be 0 !!
            step = 1
          ),
  
          checkboxInput(
            inputId = ns("cut_tail"),
            label = "Drop low quality bases from the 3' tail",
            value = TRUE   ## should be FALSE !!
          ),
  
          checkboxInput(
            inputId = ns("overrep"),
            label = "Overrepressentation analysis",
            value = TRUE
          ),
  
          checkboxInput(
            inputId = ns("paired"),
            label = "Paired end sequencing data",
            value = TRUE
          ),
  
          checkboxInput(
            inputId = ns("correction"),
            label = "Base correction (paired-end only)",
            value = TRUE    ## should be FALSE !!
          )
        )
      )
    )
  )
}

#' callFastp Server Function
#'
#' @noRd
mod_callFastp_server <- function(input, output, session, r){
  ns <- session$ns
  shinyjs::hide(id = "fastp_setup")
  
  observeEvent(eventExpr = r$show_settings, handlerExpr = {
    if (r$show_settings) {
      shinyjs::show(id = "fastp_setup")
    } else {
      shinyjs::hide(id = "fastp_setup")
    }
  })

  observeEvent(eventExpr = input$run_fastp, handlerExpr = {
    samples <- dplyr::pull(r$meta, Sample) %>%
      unique

    withProgress(
      max = length(samples) + 1, value = 0,
      message = paste("Running fastp on", length(samples), "samples"),
      expr = {
        Sys.sleep(0.75)
        compressed <- "gz"

        for (smpl in samples) {

          incProgress(amount = 1, message = paste("Running fastp on", smpl))

          fastpCommand(
            fastp = input$fastp, sample = smpl, meta = r$meta,
            exp_dir = r$exp_dir, compressed = compressed,
            trim_front = input$trim_front, trim_tail = input$trim_tail,
            front_cut = input$cut_front, tail_cut = input$cut_tail,
            paired = input$paired, overrep = input$overrep, corr = input$correction,
            overwrite = input$overwrite, threads = input$threads
          )
        }
      }
    )
  })
}

# ## To be copied in the UI
# # mod_callFastp_ui("callFastp_ui_1")
#
# ## To be copied in the server
# # callModule(mod_callFastp_server, "callFastp_ui_1")

