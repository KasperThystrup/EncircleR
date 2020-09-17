#' importMetadata UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_importMetadata_ui <- function(id){
  ns <- NS(id)
  tagList(
      
    fileInput(
      inputId = ns("meta_file"),
      label = "Please upload a Metadata file",
      accept = ".tsv"
    ),

    verbatimTextOutput(outputId = ns("file_status"))
  )
}

#' importMetadata Server Function
#'
#' @noRd
mod_importMetadata_server <- function(input, output, session, r){
  ns <- session$ns

  file_check <- reactiveValues(status = "Metadata file have not yet been uploaded")

  observeEvent(eventExpr = input$meta_file, handlerExpr = {

    logger::log_info("Uploading metadata")
    r$meta <- importMetadata(meta_fn = input$meta_file$datapath)
    r$meta_ready <- FALSE

    files_exists <- checkMetadataFilepaths(meta = r$meta)

    file_check$status <- paste(
      "Missing files:",
      paste(
        names(files_exists)[!files_exists],
        collapse = "\n"
      ),
      "Please recheck the metadata file!", sep = "\n"
    )

    if (all(files_exists)) {
      file_check$status <- "All sample files were located, ready to continue!"
      r$meta_ready <- TRUE
    }
  })

  output$file_status <- renderText(file_check$status)
}

# ## To be copied in the UI
# # mod_importMetadata_ui("importMetadata_ui_1")
#
# ## To be copied in the server
# # callModule(mod_importMetadata_server, "importMetadata_ui_1")

