#' callFastp UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shinyjs hide show
mod_callFastp_ui <- function(id){
  ns <- shiny::NS(id)
  shiny::tagList(

    shiny::div(
      id = ns("fastp_setup"),

      shiny::textInput(
        inputId = ns("fastp"),
        label = "Please enter the system command or path to program",
        value = "~/miniconda3/bin/fastp",
        placeholder = "Provide command or path for fastp binary"
      ),
      shiny::helpText(
        "Usually the binary file for fastp can be found in the `fastp/bin/fastp`, eg:",
        "/home/user/trimmers/fastp/bin/fastp OR /home/user/miniconda/pkgs/fastp-[version]/bin/fastp"
      ),

      shiny::sliderInput(
        inputId = ns("threads"),
        label = "Determine number of cores",
        min = 1,
        max = max_cores,
        value = 1,
        step = 1
      ),

      shiny::actionButton(
        inputId = ns("run_fastp"),
        label = "Begin read QC and Trimming",
        icon = shiny::icon("sliders-h")
      ),

      shiny::checkboxInput(
        inputId = ns("overwrite"),
        label = "Overwrite existing trimmed reads",
        value = FALSE
      ),
      
      shinydashboard::box(

        title = "Advanced settings",
        collapsible = TRUE,
        collapsed = TRUE,
        shiny::numericInput(
          inputId = ns("trim_front"),
          label = "Bases trimmed at the 5' tail",
          value = 7,  ## should be 0 !!
          min = 0,
          step = 1
        ),

        shiny::checkboxInput(
          inputId = ns("cut_front"),
          label = "Drop low quality bases from the 5' tail",
          value = TRUE  ## should be FALSE !!
        ),

        shiny::numericInput(
          inputId = ns("trim_tail"),
          label = "Bases trimmed at the 3' tail",
          value = 7,
          min = 0,  ## should be 0 !!
          step = 1
        ),

        shiny::checkboxInput(
          inputId = ns("cut_tail"),
          label = "Drop low quality bases from the 3' tail",
          value = TRUE   ## should be FALSE !!
        ),

        shiny::checkboxInput(
          inputId = ns("overrep"),
          label = "Overrepressentation analysis",
          value = TRUE
        ),

        shiny::checkboxInput(
          inputId = ns("paired"),
          label = "Paired end sequencing data",
          value = TRUE
        ),

        shiny::checkboxInput(
          inputId = ns("correction"),
          label = "Base correction (paired-end only)",
          value = TRUE    ## should be FALSE !!
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
  r$trimmed <- TRUE
  
  shinyjs::hide(id = "fastp_setup")
  shiny::observeEvent(eventExpr = r$ref_ready, handlerExpr = {
    shinyjs::hide(id = "fastp_setup")
    if (r$ref_ready)
      shinyjs::show(id = "fastp_setup")
    
  })

  shiny::observeEvent(eventExpr = input$run_fastp, handlerExpr = {
    r$fastp_ready <- FALSE
    samples <- dplyr::pull(r$meta, Sample) %>%
      unique

    shiny::withProgress(
      max = length(samples) + 1, value = 0,
      message = paste("Running fastp on", length(samples), "samples"),
      expr = {
        compressed <- "gz"
        
        r$paired <- input$paired

        for (smpl in samples) {

          shiny::incProgress(amount = 1, message = paste("Running fastp on", smpl))

          fastpCommand(
            fastp = input$fastp, sample = smpl, meta = r$meta,
            exp_dir = r$exp_dir, compressed = compressed,
            trim_front = input$trim_front, trim_tail = input$trim_tail,
            front_cut = input$cut_front, tail_cut = input$cut_tail,
            paired = input$paired, overrep = input$overrep, corr = input$correction,
            overwrite = input$overwrite, threads = input$threads
          )
        }
        shiny::incProgress(amount = 1, message = "Finished read trimmming and QC.")
        r$fastp_ready <- TRUE
      }
    )
  })
}

# ## To be copied in the UI
# # mod_callFastp_ui("callFastp_ui_1")
#
# ## To be copied in the server
# # callModule(mod_callFastp_server, "callFastp_ui_1")

