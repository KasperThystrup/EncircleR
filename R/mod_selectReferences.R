#' selectReferences UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shinyjs hide show
mod_selectReferences_ui <- function(id){
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::div(
      id = ns("ref"),
      
      shiny::selectInput(
        inputId = ns("ref_select"),
        label = "Choose an existing reference genome",
        choices = c(
          "Please select a reference genome" = NA,
          available_references),
      ),
      
      shiny::verbatimTextOutput(outputId = ns("ref_status"), placeholder = TRUE),
      
      shiny::column(
        width = 6,
        
        shiny::actionButton(
          inputId = ns("ref_new"),
          label = "New Reference Genome",
          icon = shiny::icon("plus-circle")
        )
      ),
      
      shiny::column(
        width = 6,
        shiny::actionButton(
          inputId = ns("continue"),
          label = "Load existing reference genome",
          icon = shiny::icon("play")
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
  
  shinyjs::hide(id = "ref")
  shiny::observeEvent(eventExpr = r$exp_ready, handlerExpr = {
    shinyjs::hide(id = "ref")
    if (r$exp_ready)
      shinyjs::show(id = "ref")
  })
  
  shinyjs::hideElement(id = "continue")
  
  msgs <- shiny::reactiveValues(status = "No reference genome selected.")
  shiny::observeEvent(eventExpr = input$ref_select, handlerExpr = {
    shiny::withProgress(
      value = 0, session = session, message = "Searching for existing files",
      expr = {
        shinyjs::showElement(id = "ref_new")
        r$cache_dir <- "~/.EncircleR"
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
          r$genome_dir <- file.path(r$cache_dir, "Genome", r$rel, r$org)
          
          logger::log_debug("Ensuring Genome index directory exists")
          r$star_dir <- file.path(r$genome_dir, "STAR")
          
          msgs$status <- "Genome index not found, please select `New Reference Genome`."

          if (dir.exists(r$star_dir)) {
            
            shiny::incProgress(
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
  
  shiny::observeEvent(eventExpr = input$ref_new, handlerExpr = {
    if (!r$ref_ready)
      r$select_ready <- TRUE
  })
    
  output$ref_status <- shiny::renderText(msgs$status)
}
    
## To be copied in the UI
# mod_selectReferences_ui("selectReferences_ui_1")
    
## To be copied in the server
# callModule(mod_selectReferences_server, "selectReferences_ui_1")
 
