#' deplyCirculaR UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @import circulaR
#' @importFrom shiny NS tagList 
#' @importFrom AnnotationHub subset
mod_deplyCirculaR_ui <- function(id){
  ns <- NS(id)
  tagList(
    div(
      id = ns("circ_call"),
      div(
        textInput(
          inputId = ns("exp_name"),
          label = "Name the experiment",
          value = "Test",
          placeholder = "Please provide a name for your experiment"
        ),
        
        selectInput(
          inputId = ns("direction"),
          label = "Sequencing directionality",
          choices = c(
            "First read first strand" = TRUE,
            "First read second strand" = FALSE,
            "Unstranded" = NULL
          ),
        ),
        
        checkboxInput(inputId = ns("paired"), label = "Paired end reads", value = TRUE),
        
        checkboxInput(
          inputId = ns("circ_qc"),
          label = "Calculate quality parametrics",
          value = TRUE
        ),
        
        sliderInput(
          inputId = ns("threads"),
          label = "Determine number of cores",
          min = 0,
          max = max_cores,
          value = 0,
          step = 1
        ),
        
        actionButton(
          inputId = ns("circular"),
          label = "Perform circRNA analysis",
          icon = icon("circle-notch")
        )
      ), 
      
      shinydashboard::box(
        title = "Advanced settings",
        collapsible = TRUE,
        collapsed = TRUE,
        
        checkboxInput(
          inputId = ns("chr_standard"),
          label = "Use standard chromosomes",
          value = TRUE
        ),
        helpText("Disable if you wish to inlcude chromosome patches as well."),
        
        checkboxInput(
          inputId = ns("sjdb_overwrite"),
          label = "Overwrite existing splice junction databases",
          value = FALSE
        ),
        helpText(
          "Enable if the process fails during generation of database of known splice junction sites"
        ),
        
        numericInput(
          inputId = ns("max_genom_dist"),
          label = "Max genomic distance",
          value = 1e5,
          step = 1
        ),
        
        checkboxInput(
          inputId = ns("span_only"),
          label = "Only include Backsplice junction Spanning reads (enable this to exclude backsplice spanning reads=",
          value = TRUE
        ),
        
        checkboxInput(
          inputId = ns("rm_bad_pairs"),
          label = "Remove bad read mate pairs",
          value = TRUE
        )
      )
    ),
    div(
      id = ns("filter"),
      
      shinydashboard::box(
        title = "Filtration",
        
        sliderInput(
          inputId = ns("min_samples"), 
          label = "Minimum sample abbundance", 
          value = 1,
          min = 1,
          max = 1
        ),
        
        sliderInput(
          inputId = ns("min_count"),
          label = "Minimum count value",
          value = 1,
          min = 1,
          max = 1
        ),
        
        actionButton(
          inputId = ns("filter_reads"),
          label = "Filter reads",
          icon = icon("funnel")
        ),
        
        checkboxInput(
          inputId = ns("filter_cleanup"),
          label = "Remove backsplice reads that fails filtration criteria",
          value = TRUE
        ),
        
        helpText("Chose this option to clean up RAM and object size"),
        
        actionButton(
          inputId = ns("save"), label = "Save object", icon = icon("save")
        )
      )
    )
  )
}
    
#' deplyCirculaR Server Function
#'
#' @noRd 
mod_deplyCirculaR_server <- function(input, output, session, r){
  ns <- session$ns
  
  hide(id = "circ_call")
  observeEvent(eventExpr = r$star_ready, handlerExpr = {
    hide(id = "circ_call")
    if (r$star_ready)
      show(id = "circ_call")
  })
  
  shinyjs::hideElement(id = "circular")
  
  observeEvent(eventExpr = input$threads, handlerExpr = {
    shinyjs::hideElement(id = "circular")
    if (input$threads > 0 & !is.null(input$exp_name))
      shinyjs::showElement(id = "circular")
  })
  
  hide(id = "filter")
  observeEvent(eventExpr = r$filt_ready, handlerExpr = {
    hide(id = "filter")
    if (r$filt_ready){
      nsamples <- samples(r$object) %>% length
      
      updateSliderInput(
        session = session,
        inputId = "min_samples",
        max = nsamples
      )
      
      meancount <- bsj.reads(object) %>% lapply(nrow) %>% unlist %>% mean
      ncount <- 0.01 * meancount %>% round
      
      updateSliderInput(
        session = session,
        inputId = "min_count",
        max = ncount
      )
      
      show(id = "filter")
    }
      
  })
  
  observeEvent(eventExpr = input$circular, handlerExpr = {
    withProgress(
      value = 0, session = session, message = "Initiating circRNA analysis",
      expr = {
        
        r$filt_ready <- FALSE
        
        incProgress(
          amount = 0.15, session = session, 
          message = "Checking for exising datasets"
        )
        
        r$exp_file <- file.path(r$cache_dir, "Saves", paste.(input$exp_name, "RData"))
        if (file.exists(r$exp_file)) {
          object <-  readRDS(r$exp_file)
        } else {
        
          incProgress(
            amount = 0.15, session = session, 
            message = "Getting EnsDb object for annotation"
          )
          ah_title <- paste(
            "Ensembl", extractEnsemblReleaseNumerics(r$rel), "EnsDb for", names(r$org)
          )
  
          ahdb <- AnnotationHub::subset(r$ah, title == ah_title)
          if (length(ahdb) != 1)
            stop("Something went wrong, select or create a new reference gnome!")
          
          ahdb <- ahdb[[names(ahdb)]]
          
          incProgress(
            amount = 0.15, session = session,
            message = "Generating database of known splice junctions. This can take some time!"
          )
          
          known_junctions <- circulaR::constructSJDB(
            annotationDB = ahdb, force = input$sjdb_overwrite
          )
          
          chrom <- seqlevels(ahdb)
          if (input$chr_standard)
            chrom <- standardChromosomes(ahdb)
          
          incProgress(
            amount = 0.15, session = session,
            message = "Importing backsplice junction reads"
          )
          
          object <- circulaR::circExperiment(
            path = r$exp_dir,
            name = input$exp_name
          )
          
          if (input$paired & is.null(input$direction)) {
            updateSelectInput(session = session, inputId = "Direction", selected = FALSE)
          } else {
            r$direction <- as.logical(input$direction)  ## Input is not logical
          }
          
          object <- circulaR::locateSamples(
            object = object, organism = r$org, gb = r$build,
            firstread.firststrand = r$direction, paired.end = input$paired
          )
          
          browser()
          object <- circulaR::readBSJdata(
            object = object,
            chromosomes = chrom,
            maxGenomicDist = input$max_genom_dist,
            onlySpanning = FALSE,
            removeBadPairs = FALSE,
            cores = input$threads
          )
          
          object <- circulaR::readLSJdata(
            object = object,
            chromosomes = chrom,
            cores = input$threads
          )
          
          incProgress(
            amount = 0.15, session = session,
            message = "Comparing backsplice junction to known splice sites"
          )
          
          object <- circulaR::compareToKnownJunctions(
            object = object, known.junctions = known_junctions,
            cores = input$threads
          )
          
          incProgress(
            amount = 0.15, session = session,
            message = "calculating overall backsplice junction statistics"
          )
          
          object <- circulaR::summarizeBSJreads(
            object = object, cores = input$threads, applyFilter = TRUE
          )
          
          incProgress(
            amount = 0.15, session = session,
            message = "Updating filters"
          )
          
          if (input$rm_bad_pairs) {
            PEok_filter <- lapply(circulaR::bsj.reads(object), function(sample) {
              dplyr::pull(sample, PEok)
            })
            
            object <- circulaR::addFilter(
              object = object, filter = PEok_filter, mode = "strict"
            )
          }
          
          if (input$span_only) {
            span_filt <- lapply(circulaR::bsj.reads(object), function(sample) {
              types <- dplyr::pull(sample, X7)
              
              types > -1
            })
            
            r$filt_ready <- TRUE
            
            object <- circulaR::addFilter(
              object = object, filter = span_filt, mode = "strict"
            )
          }
        }
        
        r$exp_name <- input$exp_name
        r$object <- object
      })
    
  })
  
  observeEvent(eventExpr = input$filter_reads, handlerExpr = {
    
    # Generate filter that ensures BSJ are covered with in 1 or more samples with more than one read
    low_abbund_tab <- bsj.reads(object, returnAs = "table") %>%
      dplyr::filter(include.read) %>%
      group_by(bsID) %>%
      summarise(n.samples = length(unique(sample.id)), totalCount = n()) %>%
      dplyr::filter(n.samples >= input$min_sample & totalCount >= input$min_count) %>%
      .$bsID
    
    # Convert filter to list of lists
    low_abbund_filt <- bsj.reads(r$object) %>%
      lapply(function(x)x$bsID %in% low_abbund_tab)
    
    r$object <- circulaR::addFilter(r$object, low_abbund_filt, mode = "strict")
    
    # Convert filter to list of lists
    count_filt <- bsj.reads(object) %>%
      lapply(function(x)x$bsID %in% count_filt_tab)
    
    r$object <- circulaR::addFilter(
      object = r$object, filter = count_filt, mode = "strict"
    )
    
    if (input$filter_cleanup) {
      bsj.reads(r$object) <- lapply(bsj.reads(r$object), function(smpl) {
        dplyr::filter(smpl, include.read)
      })
      
      r$object <- summarizeBSJreads(r$object)
    }
  })

  observeEvent(eventExpr = input$save, handlerExpr = {
    saveRDS(object = r$object, file  = r$exp_file)
  })
}
    
## To be copied in the UI
# mod_deplyCirculaR_ui("deplyCirculaR_ui_1")
    
## To be copied in the server
# callModule(mod_deplyCirculaR_server, "deplyCirculaR_ui_1", r)
 
