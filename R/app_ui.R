source("R/utils_DEFAULTS.R")

#' The application User-Interface
#' 
#' @param request Internal parameter for `{shiny}`. 
#'     DO NOT REMOVE.
#' @importFrom shinyjs hide hideElement show showElement useShinyjs
#' @importFrom shiny actionButton checkboxInput column div fileInput helpText icon incProgress NS numericInput observeEvent plotOutput reactiveValues renderPlot renderText selectInput sliderInput tagList textInput updateSelectInput updateSliderInput verbatimTextOutput withProgress
#' @importFrom shinydashboard box dashboardBody dashboardHeader dashboardPage dashboardSidebar menuItem sidebarMenu tabItem tabItems
#' @noRd
app_ui <- function(request) {
  shiny::tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    shinyjs::useShinyjs(),
    
    # List the first level UI elements here 
    shinydashboard::dashboardPage(
      header = shinydashboard::dashboardHeader(
        title = "EncircleR"
      ),
      
      sidebar = shinydashboard::dashboardSidebar(
        shinydashboard::sidebarMenu(
          # shinydashboard::menuItem(
          #   tabName = "home",
          #   icon = shiny::icon("home"),
          #   text = "Home"
          # ),
          
          shinydashboard::menuItem(
            tabName = "setup",
            icon = shiny::icon("vials"),
            text = "Experimental setup"
          ),
          
          shinydashboard::menuItem(
            tabName = "preparation",
            icon = shiny::icon("dna"),
            text = "Read preparation"
          ),
          
          shinydashboard::menuItem(
            tabName = "circ",
            icon = shiny::icon("microscope"),
            text = "CircRNA analysis"
          ),
          
          shinydashboard::menuItem(
            tabName = "statistics",
            icon = shiny::icon("chart-area"),
            text = "Statstics"
          ),
          
          shinydashboard::menuItem(
            tabName = "circtables",
            icon = shiny::icon("table"),
            text = "Detected circRNA"
          )
        )
      ),
        
      body = shinydashboard::dashboardBody(
        shinydashboard::tabItems(
          # shinydashboard::tabItem(
          #   tabName = "home",
          #   shiny::tags$h1("Welcome!")
          # ),
          
          shinydashboard::tabItem(
            tabName = "setup",
            shiny::column(
              width = 4,
              mod_importMetadata_ui("importMetadata_ui_1"),
              mod_setupExperiment_ui("setupExperiment_ui_1")
            ),
            
            shiny::column(
              width = 4,
              mod_selectReferences_ui("selectReferences_ui_1"),
              mod_getAnnotation_ui("getAnnotation_ui_1")
            ),
            
            shiny::column(
              width = 4,
              mod_STAR_idx_ui("STAR_idx_ui_1")
            )
          ),
          
          shinydashboard::tabItem(
            tabName = "preparation",
            shiny::column(
              width = 6,
              mod_callFastp_ui("callFastp_ui_1")
            ),
            
            shiny::column(
              width = 6,
              mod_STAR_call_ui("STAR_call_ui_1")
            )
          ),
          
          shinydashboard::tabItem(
            tabName = "circ",
            shiny::column(
              width = 6,
              mod_deplyCirculaR_ui("deplyCirculaR_ui_1")
            ),
            
            shiny::column(
              width = 6,
              mod_applyFilters_ui("applyFilters_ui_1")
            )
          ),
          
          shinydashboard::tabItem(
            tabName = "statistics",
            mod_mappingPlots_ui("mappingPlots_ui_1")
          ),
          
          shinydashboard::tabItem(
            tabName = "circtables",
            mod_circTable_ui("circTable_ui_1")
          )
        )
      ),
      title = "EncircleR"
    )
  )
}

#' Add external Resources to the Application
#' 
#' This function is internally used to add external 
#' resources inside the Shiny application. 
#' 
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function(){
  
  add_resource_path(
    'www', app_sys('app/www')
  )
 
  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys('app/www'),
      app_title = 'EncircleR'
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert() 
  )
}

