#' selectReferences UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_selectReferences_ui <- function(id){
  ns <- NS(id)
  tagList(
    selectInput(
      inputId = ns("ref_select"),
      label = "Choose an existing reference genome",
      choices = c(
        "Please select a reference genome" = NA,
        available_references),
    ),
    
    verbatimTextOutput(outputId = ns("ref_status"), placeholder = TRUE),
    
    actionButton(
      inputId = ns("ref_new"),
      label = "New Reference Genome",
      icon = icon("plus-circle")
    )
  )
}
    
#' selectReferences Server Function
#'
#' @noRd 
mod_selectReferences_server <- function(input, output, session, r){
  ns <- session$ns
  msgs <- reactiveValues(status = "No reference genome selected.")
  
  observeEvent(eventExpr = input$ref_select, handlerExpr = {
    shinyjs::showElement(id = "ref_new")
    
    if (input$ref_select %in% available_references) {
      shinyjs::hideElement(id = "ref_new")
      
      ref_name <- strsplit(x = input$ref_select, split = "/") %>%
        unlist %>%
        tail(2) %>%
        gsub(pattern = "_|-", replacement = " ") %>%
        paste(collapse = " ")
      
      ref_select <- input$ref_select
      names(ref_select) <- paste("Ensembl", ref_name)
      
      shinyjs::hideElement(id = "ref_new")
      
      logger::log_info("Determining selected reference genome")
      reference <- str_split(string = names(ref_select), pattern = " ") %>%
        unlist
      
      logger::log_debug("Determining selected organism")
      r$org <- head(x = reference, 2) %>%
        paste(collapse = "_")
      names(r$org) <- gsub(pattern = "_", replacement = " ", x = r$org)
      
      logger::log_debug("Determining selected release")
      r$rel <- tail(x = reference, 2) %>%
        paste(collapse = "_")
      names(r$rel) <- gsub(pattern = "_", replacement = " ", x = r$rel)
      
      logger::log_debug("Determining selected build")
      build.idx <- match(input$org, names(supported_builds))  ## Found in utils_supportedOrganism
      build <- supported_builds[build.idx]
      r$build <- build
      
      logger::log_debug("Determining reference genome directory")
      r$genome_dir <- file.path("~/.EncircleR/Genome", r$rel, r$org)
      
      logger::log_debug("Ensuring Genome index directory exists")
      r$star_dir <- file.path(r$genome_dir, "STAR")
      
      
      if (!dir.exists(r$star_dir)) {
        msgs$status <- "Genome index directory was not found, please generate a new reference genome by selecting `New Reference Genome`."
        r$ref_ready <- FALSE
        shinyjs::showElement(id = "ref_new")
      } else {
        msgs$status <- "Reference genome selected"
        r$show_idx <- FALSE
        r$ref_ready <- TRUE
      }
    }
  })
  
  observeEvent(eventExpr = input$ref_new, handlerExpr = {
    if (!r$ref_ready)
      r$show_idx <- TRUE
  })
  
  output$ref_status <- renderText(msgs$status)
}
    
## To be copied in the UI
# mod_selectReferences_ui("selectReferences_ui_1")
    
## To be copied in the server
# callModule(mod_selectReferences_server, "selectReferences_ui_1")
 
