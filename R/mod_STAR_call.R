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
      id = ns("star_call"),
      shinydashboard::box(
        # textInput(
        #   inputId = ns("sample_file"),
        #   label = "Provide the full path to the top directory of the experiment",
        #   value = "STAR"
        # ),

        # checkboxInput(
        #   inputId = ns("paired"),
        #   label = "Paired end reads",
        #   value = TRUE
        # ),

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

        actionButton(
          inputId = ns("call"),
          label = "Begin alignment",
          icon = icon("star") # align-center ## microscope
        )
      )
    )
  )
}

#' STAR_call Server Function
#'
#' @noRd
mod_STAR_call_server <- function(input, output, session, r){
  ns <- session$ns

  observeEvent(eventExpr = input$call, handlerExpr = {
    logger::log_debug("Generating sample data table")

    smpl <- dplyr::pull(r$meta, Sample) %>%
      unique

    # Progress counter

    withProgress(value = 0, min = 0, max = length(smpl) + 2, message = "Initiating STAR alignment", expr = {
      Sys.sleep(0.75)
      incProgress(
        amount = 0.15, session = session,
        message = "Loading genome index"
      )

      incProgress(amount = 1, message = "Attaching Genome into memory")
      browser()
      attachSTARGenome(star = r$star, genome_dir = r$star_dir)

      lapply(smpl, function(smpl){

        sample_subset <- subset(r$meta, Sample == smpl)
        incProgress(amount = 1, message = paste("Aligning sample:", smpl))
        callSTAR(
          star = r$star, genome_dir = r$star_dir,
          threads = r$threads, sample = smpl, meta = r$meta,
          paired = r$paired, out_dir = r$exp_dir,
          RAM_limit = input$ram_lim, chim_segMin = input$min_seq,
          compression = "gz"
        )
      })

      incProgress(amount = 1, message = "Dettaching genome and cleaning up")
      dettachSTARGenome(star = r$star, genome_dir = star_dir)
    })
  })



}

### To be copied in the UI
## mod_STAR_call_ui("STAR_call_ui_1")

### To be copied in the server
## callModule(mod_STAR_call_server, "STAR_call_ui_1")

