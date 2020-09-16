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
    div(
      id = ns("ref"),
      
      selectInput(
        inputId = ns("ref_select"),
        label = "Choose an existing reference genome",
        choices = c(
          "Please select a reference genome" = NA,
          available_references),
      ),
      
      verbatimTextOutput(outputId = ns("ref_status"), placeholder = TRUE),
      
      column(
        width = 6,
        
        actionButton(
          inputId = ns("ref_new"),
          label = "New Reference Genome",
          icon = icon("plus-circle")
        )
      ),
      
      column(
        width = 6,
        actionButton(
          inputId = ns("continue"),
          label = "Load existing reference genome",
          icon = icon("play")
        )
      )
    )
  )
}
    
#' selectReferences Server Function
#'
#' @noRd 
mod_selectReferences_server <- function(input, output, session, r){
  ns <- session$ns
  
  hide(id = "ref")
  observeEvent(eventExpr = r$exp_ready, handlerExpr = {
    hide(id = "ref")
    if (r$exp_ready)
      show(id = "ref")
  })
  
  shinyjs::hideElement(id = "continue")
  # shinyjs::hideElement(id = "ref_select")
  # shinyjs::hideElement(id = "ref_status")
  # # shinyjs::hideElement(id = "ref_new")
  # observeEvent(eventExpr = r$exp_ready, handlerExpr = {
  #   shinyjs::hideElement(id = "ref_select")
  #   shinyjs::hideElement(id = "ref_status")
  #   # shinyjs::hideElement(id = "ref_new")
  #   if (r$exp_ready){
  #     shinyjs::showElement(id = "ref_select")
  #     shinyjs::showElement(id = "ref_status")
  #     # shinyjs::showElement(id = "ref_new")
  #   }
  # })
  
  msgs <- reactiveValues(status = "No reference genome selected.")
  observeEvent(eventExpr = input$ref_select, handlerExpr = {
    withProgress(
      value = 0, session = session, message = "Searching for existing files",
      expr = {
        shinyjs::showElement(id = "ref_new")
        r$cache_dir <- "~/.EncircleR/Genome"
        r$ref_ready <- FALSE
        
        if (input$ref_select %in% available_references) {
          # shinyjs::hideElement(id = "ref_new")
          
          ref_name <- strsplit(x = input$ref_select, split = "/") %>%
            unlist %>%
            tail(2) %>%
            gsub(pattern = "_|-", replacement = " ") %>%
            paste(collapse = " ")
          
          ref_select <- input$ref_select
          names(ref_select) <- paste("Ensembl", ref_name)
          
          # shinyjs::hideElement(id = "ref_new")
          
          logger::log_info("Determining selected reference genome")
          reference <- str_split(string = names(ref_select), pattern = " ") %>%
            unlist
          
          logger::log_debug("Determining selected organism")
          r$org <- tail(x = reference, 2) %>%
            paste(collapse = "_")
          names(r$org) <- gsub(pattern = "_", replacement = " ", x = r$org)
          
          logger::log_debug("Determining selected release")
          r$rel <- head(x = reference, 3) %>%
            tail(2) %>%
            paste(collapse = "-")
          names(r$rel) <- gsub(pattern = "_", replacement = " ", x = r$rel)
          
          logger::log_debug("Determining selected build")
          build.idx <- match(r$org, names(supported_builds))  ## Found in utils_supportedOrganism
          r$build <- supported_builds[build.idx]
          
          logger::log_debug("Determining reference genome directory")
          r$genome_dir <- file.path(r$cache_dir, r$rel, r$org)
          
          logger::log_debug("Ensuring Genome index directory exists")
          r$star_dir <- file.path(r$genome_dir, "STAR")
          
          msgs$status <- "Genome index not found, please select `New Reference Genome`."
          if (dir.exists(r$star_dir)) {
            incProgress(
              amount = 0.25, session = session, 
              message = "Reference files found, loading AnnotationHub."
            )
            msgs$status <- "Reference genome selected.\nPlease continue to `Read preparation`"
            shinyjs::hideElement(id = "ref_new")
            r$select_ready <- FALSE
            r$ref_ready <- TRUE
            r$star_dir <- file.path(r$genome_dir, "STAR")
            r$ah <- AnnotationHub::AnnotationHub()
          }
        }
      }
    )
  })
  
  observeEvent(eventExpr = input$ref_new, handlerExpr = {
    if (!r$ref_ready)
      r$select_ready <- TRUE
  })
    
  output$ref_status <- renderText(msgs$status)
}
    
## To be copied in the UI
# mod_selectReferences_ui("selectReferences_ui_1")
    
## To be copied in the server
# callModule(mod_selectReferences_server, "selectReferences_ui_1")
 
