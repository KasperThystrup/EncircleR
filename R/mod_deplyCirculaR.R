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
          label = "Please provide a name for your experiment",
          value = "",
          placeholder = "Experiment_name"
        ),
        helpText("This will be used to as filename for the finsihed circRNA RData object, so please avoid using spaces and special characters."),
        
        selectInput(
          inputId = ns("direction"),
          label = "Sequencing directionality",
          choices = c(
            "First read first strand" = TRUE,
            "First read second strand" = FALSE,
            "Unstranded" = NA
          ),
        ),
        helpText(
          "This information is used to determine whether or not,",
          "the sequencing data represents the reverse complement of the sample template RNA.",
          "For TruSeq stranded libraries use First read first strand."
        ),
        
        checkboxInput(inputId = ns("paired"), label = "Paired end reads", value = TRUE),
        helpText(
          "Currently, only paired-end sequencing data are tested, supported, and recommended."
        ),
        
        checkboxInput(
          inputId = ns("circ_qc"),
          label = "Calculate quality parametrics",
          value = TRUE
        ),
        
        sliderInput(
          inputId = ns("threads"),
          label = "Determine number of cores",
          min = 1,
          max = max_cores,
          value = 4,
          step = 1
        ),
        
        checkboxInput(
          inputId = ns("overwrite"),
          label = "Overwrite previous circRNA object",
          value = FALSE
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
  
  observeEvent(eventExpr = input$circular, handlerExpr = {
    withProgress(
      value = 0, session = session, message = "Fetching gene annotation object",
      expr = {
        
        ah_title <- paste(
          "Ensembl", extractEnsemblReleaseNumerics(r$rel), "EnsDb for", names(r$org)
        )
    
        r$ahdb <- AnnotationHub::subset(r$ah, title == ah_title)
        if (length(r$ahdb) != 1)
          stop("Something went wrong, select or create a new reference gnome!")
        
        r$ahdb <- r$ahdb[[names(r$ahdb)]]
        
        r$exec <- Sys.time()
        
        r$filt_ready <- FALSE
        
        incProgress(
          amount = 0.15, session = session, 
          message = "Checking for exising datasets"
        )
        
        r$exp_file <- file.path(r$cache_dir, "Saves", paste.(input$exp_name, "RData"))
        if (file.exists(r$exp_file) & !input$overwrite) {
          incProgress(amount = 0.55, session = session, message = "Loading existing dataset")
          object <-  readRDS(r$exp_file)
        } else {
          
          cmd_makedir <- paste("mkdir", dir_name(r$exp_file))
          
          system(cmd_makedir)
          
          incProgress(
            amount = 0.15, session = session,
            message = "Generating database of known splice junctions. This can take some time!"
          )
          
          known_junctions <- circulaR::constructSJDB(
            annotationDB = r$ahdb, force = input$sjdb_overwrite
          )
          
          chrom <- seqlevels(r$ahdb)
          if (input$chr_standard)
            chrom <- standardChromosomes(r$ahdb)
          
          incProgress(
            amount = 0.15, session = session,
            message = "Importing backsplice junction reads"
          )
          
          object <- circulaR::circExperiment(
            path = r$exp_dir,
            name = input$exp_name
          )
          
          if (input$paired & is.na(input$direction)) {
            updateSelectInput(session = session, inputId = "Direction", selected = FALSE)
          } else {
            r$direction <- as.logical(input$direction)  ## Input is not logical
          }
          
          object <- circulaR::locateSamples(
            object = object, organism = r$org, gb = r$build,
            firstread.firststrand = r$direction, paired.end = input$paired
          )
          
          object <- circulaR::readBSJdata(
            object = object,
            chromosomes = chrom,
            maxGenomicDist = input$max_genom_dist,
            onlySpanning = FALSE,
            removeBadPairs = FALSE,
            cores = 1
          )
          
          object <- circulaR::readLSJdata(
            object = object,
            chromosomes = chrom,
            cores = 1
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
            object = object,
            cores = input$threads,
            applyFilter = TRUE
          )
          
        }
        r$filt_ready <- TRUE
        r$exp_name <- input$exp_name
        r$object <- object
        r$circ_ready = TRUE # Should be filt_ready??
      })
    
    logger::log_info(
      "CircRNA analysis for all samples: ", 
      difftime(time1 =  r$exec, time2 = Sys.time(), units = "secs")
    )
    
  })
}
    
## To be copied in the UI
# mod_deplyCirculaR_ui("deplyCirculaR_ui_1")
    
## To be copied in the server
# callModule(mod_deplyCirculaR_server, "deplyCirculaR_ui_1", r)
 
