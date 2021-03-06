#' applyFilters UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shinyjs hide show
mod_applyFilters_ui <- function(id){
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::div(
      id = ns("filter"),
      
      shiny::sliderInput(
        inputId = ns("min_samples"), 
        label = "Minimum sample abbundance", 
        value = 1,
        min = 1,
        max = 1,
        step = 1
      ),
      
      shiny::sliderInput(
        inputId = ns("min_count"),
        label = "Minimum count value",
        value = 1,
        min = 1,
        max = 20,
        step = 1
      ),
      
      shiny::checkboxInput(
        inputId = ns("span_only"),
        label = "Only include Backsplice junction Spanning reads (enable this to exclude backsplice spanning reads)",
        value = TRUE
      ),
      
      shiny::checkboxInput(
        inputId = ns("rm_bad_pairs"),
        label = "Remove bad read mate pairs",
        value = TRUE
      ),
      
      shiny::checkboxInput(
        inputId = ns("junctionoverlap"),
        label = "Only keep backsplice reads, which perfectly overlaps with known junction sites",
        value = TRUE
      ),
      
      
      
      shiny::helpText("Chose this option to clean up RAM and object size"),
      
      shiny::verbatimTextOutput(outputId = ns("circs")),
      
      shiny::column(
        width = 6, 
        shiny::actionButton(
          inputId = ns("filter_reads"),
          label = "Filter reads",
          icon = shiny::icon("funnel")
        )
      ),
      
      shiny::column(
        width = 6,
        shiny::actionButton(
          inputId = ns("save"),
          label = "Save object",
          icon = shiny::icon("save")
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
  
  shinyjs::hide(id = "filter")
  shiny::observeEvent(eventExpr = r$filt_ready, handlerExpr = {
    shinyjs::hide(id = "filter")
    if(r$filt_ready) {
      
      nsamples <- samples(r$object) %>%
        length
      shiny::updateSliderInput(session = session, inputId = "min_samples", max = nsamples)
      
      shinyjs::show(id = "filter")
    }
  })
  
  shiny::observeEvent(
    eventExpr = input$filter_reads,
    handlerExpr = {
      shiny::withProgress(
        value = 0,
        message = "Resetting fitlered reads",
        expr = {
          bsj.reads(r$object) <- lapply(bsj.reads(r$object), function(x) {
            x$include.read <- TRUE
            return(x)
          })
          
          r$circ_ready <- FALSE
          
          shiny::incProgress(
            amount = 0.15,
            session = session,
            message = "Updating filters"
          )
          
          if (input$rm_bad_pairs) {
            PEok_filter <- lapply(circulaR::bsj.reads(r$object), function(sample) {
              dplyr::pull(sample, PEok)
            })
            
            r$object <- circulaR::addFilter(
              object = r$object,
              filter = PEok_filter,
              mode = "strict"
            )
          }
          
          if (input$span_only) {
            span_filt <- lapply(circulaR::bsj.reads(r$object), function(sample) {
              types <- dplyr::pull(sample, X7)
              
              types > -1
            })
            
            r$object <- circulaR::addFilter(
              object = r$object, filter = span_filt, mode = "strict"
            )
          }
          
          if (input$junctionoverlap) {
            shiny::incProgress(
              amount = 0.15,
              message = "Filtering by perfect donor and acceptor overlap"
            )
            
            bsID_summarized <- bsj.reads(r$object, returnAs = "table") %>%
              dplyr::filter(include.read) %>%
              group_by(bsID) %>%
              summarize(
                donorPerfect = ifelse(
                  donor.closest.type == "donor" & shiftDonorToNearestJ == 0,
                  TRUE, FALSE
                ),
                acceptorPerfect = ifelse(
                  acceptor.closest.type == "acceptor" & shiftAcceptorToNearestJ == 0,
                  TRUE, FALSE
                ),
                
                perfectOverlap = donorPerfect & acceptorPerfect
              )
            
            bsID_passed <- dplyr::filter(
              bsID_summarized,
              perfectOverlap
            ) %>%
              dplyr::pull(bsID)
            
            
            bsID_included <- bsj.reads(r$object) %>%
              lapply(function(x)x$bsID %in% bsID_passed)
            
            r$object <- circulaR::addFilter(r$object, bsID_included, mode = "strict")
            
          }
          
          # Generate filter that ensures BSJ are covered with in 1 or more samples with more than one read
          bsID_summarized <- bsj.reads(r$object, returnAs = "table") %>%
            dplyr::filter(include.read) %>%
            group_by(bsID) %>%
            summarise(
              n.samples = length(unique(sample.id)),
              totalCount = n()
            )
          
          
          shiny::incProgress(amount = 0.5, session = session, message = "Identifying passed backsplice reads")
          
          # Filter by minimal sample abbundance and count.
          bsID_passed <- dplyr::filter(
            bsID_summarized,
            n.samples >= input$min_samples & totalCount >= input$min_count
          ) %>%
            dplyr::pull(bsID)
          
          # Convert filter to list of lists
          bsID_included <- bsj.reads(r$object) %>%
            lapply(function(x)x$bsID %in% bsID_passed)
          
          
          shiny::incProgress(amount = 0.25, session = session, message = "Updating filters and summarizing backsplice statistics")
          r$object <- circulaR::addFilter(r$object, bsID_included, mode = "strict")
          
          r$object <- summarizeBSJreads(r$object)
          
        })
    
      
      output$circs <- shiny::renderText({
        bsids <- bsj.reads(r$object, returnAs = "table") %>%
          dplyr::filter(include.read) %>%
          dplyr::pull(bsID)
        
        bsj_pool <- unique(bsids) %>%
          length
        
        paste("Unique detected backsplice junctions in the whole dataset, which passed filtration:", bsj_pool)
      })
      
      
      object_filtered <- r$object
      bsj.reads(object_filtered) <- lapply(
        bsj.reads(r$object), function(x) dplyr::filter(x, include.read) %>% return
      )
      
      r$object_filtered <- circulaR::summarizeBSJreads(object_filtered)
      
      r$circ_ready <- TRUE
      logger::log_info(
        "CircRNA analysis and filtration finsihed: ",
        difftime(time1 =  r$exec, time2 = Sys.time(), units = "secs")
      )
    })
  
  shiny::observeEvent(eventExpr = input$save, handlerExpr = {
    shiny::withProgress(value = 0.50, message = "Setting up output directory", expr = {
      dir.create(r$exp_dir)
      saveRDS(object = r$object, file  = r$exp_file)
    })
  })
}

## To be copied in the UI
# mod_applyFilters_ui("applyFilters_ui_1")

## To be copied in the server
# callModule(mod_applyFilters_server, "applyFilters_ui_1")

