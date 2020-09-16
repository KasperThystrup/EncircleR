#' The application User-Interface
#' 
#' @param request Internal parameter for `{shiny}`. 
#'     DO NOT REMOVE.
#' @import shiny
#' @import shinydashboard
#' @importFrom shinyjs useShinyjs hideElement showElement
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    shinyjs::useShinyjs(),
    
    # List the first level UI elements here 
    shinydashboard::dashboardPage(
      header = dashboardHeader(
        title = "EncircleR - Fully automated circRNA analysis"
      ),
      sidebar = dashboardSidebar(
        sidebarMenu(
          menuItem(
            tabName = "home",
            icon = icon("home"),
            text = "Home"
          ),
          
          menuItem(
            tabName = "setup",
            icon = icon("vials"),
            text = "Experimental setup"
          ),
          
          menuItem(
            tabName = "preparation",
            icon = icon("dna"),
            text = "Read preparation"
          ),
          
          menuItem(
            tabName = "circ",
            icon = icon("microscope"),
            text = "CircRNA analysis"
          )
        )
      ),
        
      body = dashboardBody(
        tabItems(
          tabItem(
            tabName = "home",
            tags$h1("Welcome!")
          ),
          
          tabItem(
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
          
          tabItem(
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
          
          tabItem(
            tabName = "circ",
            mod_deplyCirculaR_ui("deplyCirculaR_ui_1")
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

