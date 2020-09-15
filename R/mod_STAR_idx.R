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
      shinydashboard::box(
        title = "Prepare STAR reference index",
        textInput(
          inputId = ns("star"),
          label = "Locate binary star file or provide default system call",
          value = "star-seq-alignment"
        ),

        sliderInput(
          inputId = ns("threads"),
          label = "Determine number of cores",
          min = 1,
          max = max_cores,
          value = 1,
          step = 1
        ),

        numericInput(
          inputId = ns("read_length"),
          label = "Read length",
          min = 1,
          value = 100
        ),

        checkboxInput(
          inputId = ns("idx_overwrite"),
          label = "Overwrite existing STAR index",
          value = FALSE
        ),

        actionButton(
          inputId = ns("idx"),
          label = "Prepare STAR index",
          icon = icon("dolly")
        )
      )
    )
  )
}

#' STAR_idx Server Function
#'
#' @noRd
mod_STAR_idx_server <- function(input, output, session, r){
  ns <- session$ns

  observeEvent(eventExpr = input$idx, handlerExpr = {
    withProgress(
      value = 0, session = session, message = "Loading STAR index", expr = {
        Sys.sleep(0.75)
        r$star <- input$star

        logger::log_debug("Defining genome directory")
        r$star_dir <- file.path(r$genome_dir, "STAR")

        idx_exists <- FALSE
        logger::log_debug("Determining whether index folder exists")
        if (dir.exists(r$genome_dir))
          idx_exists <- TRUE

        r$threads <- input$threads
        if (input$idx_overwrite | !idx_exists){
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

          if (!input$idx_overwrite)
            shinyjs::hideElement(id = "idx", anim = TRUE, animType = "fade")

        } else {
          incProgress(
            amount = 0.95, session = session,
            message = "STAR index allready exists, not overwriting."
          )
          Sys.sleep(0.75)
        }

    })
  })
}

### To be copied in the UI
## mod_STAR_idx_ui("STAR_idx_ui_1")

### To be copied in the server
## callModule(mod_STAR_idx_server, "STAR_idx_ui_1")

