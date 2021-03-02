#' The application User-Interface
#' 
#' @param request Internal parameter for `{shiny}`. 
#'     DO NOT REMOVE.
#' @importFrom shinyjs useShinyjs hideElement showElement
#' @import shiny
#' @importFrom shinydashboard dashboardBody dashboardHeader dashboardPage dashboardSidebar menuItem sidebarMenu tabItem tabItems
#' @noRd
app_ui <- function(request) {
  tagList(
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
          #   icon = icon("home"),
          #   text = "Home"
          # ),
          
          shinydashboard::menuItem(
            tabName = "setup",
            icon = icon("vials"),
            text = "Experimental setup"
          ),
          
          shinydashboard::menuItem(
            tabName = "preparation",
            icon = icon("dna"),
            text = "Read preparation"
          ),
          
          shinydashboard::menuItem(
            tabName = "circ",
            icon = icon("microscope"),
            text = "CircRNA analysis"
          ),
          
          shinydashboard::menuItem(
            tabName = "statistics",
            icon = icon("chart-area"),
            text = "Statstics"
          ),
          
          shinydashboard::menuItem(
            tabName = "circtables",
            icon = icon("table"),
            text = "Detected circRNA"
          )
        )
      ),
        
      body = shinydashboard::dashboardBody(
        shinydashboard::tabItems(
          # shinydashboard::tabItem(
          #   tabName = "home",
          #   tags$h1("Welcome!")
          # ),
          
          shinydashboard::tabItem(
            tabName = "setup",
            column(
              width = 4,
              mod_importMetadata_ui("importMetadata_ui_1"),
              mod_setupExperiment_ui("setupExperiment_ui_1")
            ),
            
            column(
              width = 4,
              mod_selectReferences_ui("selectReferences_ui_1"),
              mod_getAnnotation_ui("getAnnotation_ui_1")
            ),
            
            column(
              width = 4,
              mod_STAR_idx_ui("STAR_idx_ui_1")
            )
          ),
          
          shinydashboard::tabItem(
            tabName = "preparation",
            column(
              width = 6,
              mod_callFastp_ui("callFastp_ui_1")
            ),
            
            column(
              width = 6,
              mod_STAR_call_ui("STAR_call_ui_1")
            )
          ),
          
          shinydashboard::tabItem(
            tabName = "circ",
            column(
              width = 6,
              mod_deplyCirculaR_ui("deplyCirculaR_ui_1")
            ),
            
            column(
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
#' @import shiny
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

