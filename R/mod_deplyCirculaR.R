#' deplyCirculaR UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @import circulaR
#' @importFrom shinyjs hide show
#' @importFrom AnnotationHub subset
mod_deplyCirculaR_ui <- function(id){
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::div(
      id = ns("circ_call"),
      shiny::div(
        shiny::textInput(
          inputId = ns("exp_name"),
          label = "Please provide a name for your experiment",
          # value = , ## Not needed
          placeholder = "Experiment_name"
        ),
        shiny::helpText("This will be used to as filename for the finsihed circRNA RData object, so please avoid using spaces and special characters."),
        
        shiny::selectInput(
          inputId = ns("direction"),
          label = "Sequencing directionality",
          choices = c(
            "First read first strand" = TRUE,
            "First read second strand" = FALSE,
            "Unstranded" = NA
          ),
        ),
        shiny::helpText(
          "This information is used to determine whether or not,",
          "the sequencing data represents the reverse complement of the sample template RNA.",
          "For TruSeq stranded libraries use First read first strand."
        ),
        
        shiny::checkboxInput(inputId = ns("paired"), label = "Paired end reads", value = TRUE),
        shiny::helpText(
          "Currently, only paired-end sequencing data are tested, supported, and recommended."
        ),
        
        shiny::checkboxInput(
          inputId = ns("circ_qc"),
          label = "Calculate quality parametrics",
          value = TRUE
        ),
        
        shiny::sliderInput(
          inputId = ns("threads"),
          label = "Determine number of cores",
          min = 1,
          max = max_cores,
          value = 4,
          step = 1
        ),
        
        shiny::checkboxInput(
          inputId = ns("overwrite"),
          label = "Overwrite previous circRNA object",
          value = FALSE
        ),
        
        shiny::actionButton(
          inputId = ns("circular"),
          label = "Perform circRNA analysis",
          icon = shiny::icon("circle-notch")
        )
      ), 
      
      shinydashboard::box(
        title = "Advanced settings",
        collapsible = TRUE,
        collapsed = TRUE,
        
        shiny::checkboxInput(
          inputId = ns("chr_standard"),
          label = "Use standard chromosomes",
          value = TRUE
        ),
        shiny::helpText("Disable if you wish to inlcude chromosome patches as well."),
        
        shiny::checkboxInput(
          inputId = ns("sjdb_overwrite"),
          label = "Overwrite existing splice junction databases",
          value = FALSE
        ),
        shiny::helpText(
          "Enable if the process fails during generation of database of known splice junction sites"
        ),
        
        shiny::numericInput(
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
  
  shinyjs::hide(id = "circ_call")
  shiny::observeEvent(eventExpr = r$star_ready, handlerExpr = {
    shinyjs::hide(id = "circ_call")
    if (r$star_ready)
      shinyjs::show(id = "circ_call")
  })
  
  shiny::observeEvent(eventExpr = input$circular, handlerExpr = {
    shiny::withProgress(
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
        
        shiny::incProgress(
          amount = 0.15, session = session, 
          message = "Checking for exising datasets"
        )
        
        r$exp_file <- file.path(r$cache_dir, "Saves", paste.(input$exp_name, "RData"))
        if (file.exists(r$exp_file) & !input$overwrite) {
          shiny::incProgress(amount = 0.55, session = session, message = "Loading existing dataset")
          object <-  readRDS(r$exp_file)
        } else {
          
          cmd_makedir <- paste("mkdir", dirname(r$exp_file))
          
          system(cmd_makedir)
          
          shiny::incProgress(
            amount = 0.15, session = session,
            message = "Generating database of known splice junctions. This can take some time!"
          )
          
          known_junctions <- circulaR::constructSJDB(
            annotationDB = r$ahdb, force = input$sjdb_overwrite
          )
          
          chrom <- seqlevels(r$ahdb)
          if (input$chr_standard)
            chrom <- standardChromosomes(r$ahdb)
          
          shiny::incProgress(
            amount = 0.15, session = session,
            message = "Importing backsplice junction reads"
          )
          
          object <- circulaR::circExperiment(
            path = r$exp_dir,
            name = input$exp_name
          )
          
          if (input$paired & is.na(input$direction)) {
            shiny::updateSelectInput(session = session, inputId = "Direction", selected = FALSE)
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
          
          shiny::incProgress(
            amount = 0.15, session = session,
            message = "Comparing backsplice junction to known splice sites"
          )
          
          object <- circulaR::compareToKnownJunctions(
            object = object, known.junctions = known_junctions,
            cores = input$threads
          )
          
          
          shiny::incProgress(
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
 
