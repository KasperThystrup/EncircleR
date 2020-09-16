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
      
      textInput(
        inputId = ns("exp_name"),
        label = "Name the experiment",
        placeholder = "Please provide a name for your experiment"
      ),
      
      sliderInput(
        inputId = ns("threads"),
        label = "Determine number of cores",
        min = 0,
        max = max_cores,
        value = 0,
        step = 1
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
      
      actionButton(
        inputId = ns("circular"),
        label = "Perform circRNA analysis",
        icon = icon("circle-notch")
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
    if (input$threads > 0)
      shinyjs::showElement(id = "circular")
  })
  
  observeEvent(eventExpr = input$circular, handlerExpr = {
    withProgress(
      value = 0, session = session, message = "Initiating circRNA analysis",
      expr = {
        
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
          amount = 0.15, session = session, message = "Generating splice junction site"
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
        
        experiment <- circulaR::circExperiment(
          path = r$exp_dir,
          name = input$exp_name
        )
        
        if (input$paired & is.null(input$direction))
          updateSelectInput(session = session, inputId = "Direction", selected = FALSE)
        
        experiment <- circulaR::locateSamples(
          object = experiment, organism = r$org, gb = r$build,
          firstread.firststrand = input$direction, paired.end = input$paired
        )
        
        
        experiment <- circulaR::readBSJdata(
          object = experiment,
          chromosomes = chrom,
          cores = input$threads
        )
        
        experiment <- circulaR::readLSJdata(
          object = experiment,
          chromosomes = chrom,
          cores = input$threads
        )
        
        incProgress(
          amount = 0.15, session = session,
          message = "Comparing backsplice junction to known splice sites"
        )
        
        experiment <- circulaR::compareToKnownJunctions(
          object = experiment, known.junctions = known_junctions,
          cores = input$threads
        )
        
        experiment_nofilt <- circulaR::summarizeBSJreads(
          object = experiment, cores = input$threads, applyFilter = FALSE
        )
        
        experiment <- circulaR::summarizeBSJreads(
          object = experiment, cores = input$threads, applyFilter = TRUE
        )
      })
    
  })
 
}
    
## To be copied in the UI
# mod_deplyCirculaR_ui("deplyCirculaR_ui_1")
    
## To be copied in the server
# callModule(mod_deplyCirculaR_server, "deplyCirculaR_ui_1", r)
 
