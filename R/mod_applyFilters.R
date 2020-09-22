#' applyFilters UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_applyFilters_ui <- function(id){
  ns <- NS(id)
  tagList(
    div(
      id = ns("filter"),
      
      shinydashboard::box(
        title = "Filtration",
        
        sliderInput(
          inputId = ns("min_samples"), 
          label = "Minimum sample abbundance", 
          value = 1,
          min = 1,
          max = 1,
          step = 1
        ),
        
        sliderInput(
          inputId = ns("min_count"),
          label = "Minimum count value",
          value = 1,
          min = 0,
          max = 20,
          step = 1
        ),
        
        # checkboxInput(
        #   inputId = ns("independent"),
        #   label = "Apply filters independtently so both criteria must be true (Strict filtration)",
        #   value = FALSE
        # ),
        
        actionButton(
          inputId = ns("filter_reads"),
          label = "Filter reads",
          icon = icon("funnel")
        ),
        
        # checkboxInput(
        #   inputId = ns("filter_cleanup"),
        #   label = "Remove backsplice reads that fails filtration criteria",
        #   value = TRUE
        # ),
        
        helpText("Chose this option to clean up RAM and object size"),
        
        actionButton(
          inputId = ns("save"), label = "Save object", icon = icon("save")
        )
      )
    )
  )
}

#' applyFilters Server Function
#'
#' @noRd 
mod_applyFilters_server <- function(input, output, session, r){
  ns <- session$ns
  
  hide(id = "filter")
  observeEvent(eventExpr = r$filt_ready, handlerExpr = {
    hide(id = "filter")
    if(r$filt_ready) {
      
      nsamples <- samples(r$object) %>%
        length
      updateSliderInput(session = session, inputId = "min_samples", max = nsamples)
      
      #### Update counter as well??
      
      show(id = "filter")
    }
  })
  
  observeEvent(eventExpr = input$filter_reads, handlerExpr = {
    r$circ_ready <- FALSE
    browser()
    
    # Generate filter that ensures BSJ are covered with in 1 or more samples with more than one read
    bsID_summarized <- bsj.reads(r$object, returnAs = "table") %>%
      dplyr::filter(include.read) %>%
      group_by(bsID) %>%
      summarise(
        bsID_grouped,
        n.samples = length(unique(sample.id)),
        totalCount = n()
      )
    
    # if (input$independent) {
    
    # Filter by minimal sample abbundance and count.
    bsID_passed <- dplyr::filter(
      bsID_summarized,
      n.samples >= input$min_samples & totalCount >= input$min_count
    ) %>%
      dplyr::pull(bsID)
    
    # Convert filter to list of lists
    bsID_included <- bsj.reads(r$object) %>%
      lapply(function(x)x$bsID %in% bsID_passed)
    
    r$object <- circulaR::addFilter(r$object, bsID_included, mode = "strict")
    # } else {  ### Are there any difference in doing filter A first, then B? Contra A & B simultanously??
    #   
    #   # First filter by minimal sample abbundance
    #   bsID_passed <- dplyr::filter(
    #     bsID_summarized,
    #     n.samples >= input$min_samples
    #   )
    #   
    #   # Convert filter to list of lists
    #   bsID_included <- bsj.reads(r$object) %>%
    #     lapply(function(x)x$bsID %in% bsID_passed)
    #   
    #   r$object <- circulaR::addFilter(r$object, bsID_included, mode = "strict")
    #   
    #   # Next filter by minimal sample abbundance
    #   bsID_passed <- dplyr::filter(
    #     bsID_summarized,
    #     n.samples >= input$min_count
    #   )
    #   
    #   # Convert filter to list of lists
    #   bsID_included <- bsj.reads(r$object) %>%
    #     lapply(function(x)x$bsID %in% bsID_passed)
    #   
    #   r$object <- circulaR::addFilter(r$object, bsID_included, mode = "strict")
    # }
    
    r$object <- summarizeBSJreads(r$object)
    r$circ_ready <- TRUE
  })
  
  observeEvent(eventExpr = input$save, handlerExpr = {
    saveRDS(object = r$object, file  = r$exp_file)
  })
}

## To be copied in the UI
# mod_applyFilters_ui("applyFilters_ui_1")

## To be copied in the server
# callModule(mod_applyFilters_server, "applyFilters_ui_1")

