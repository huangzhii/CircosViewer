# 04/12/2018 Zhi Huang
library(shinyWidgets)

navbarPage(title=div(a(img(src="images/logo.png",
                           height = 35,
                           style = "margin:-5px 0px; padding-bottom: 5px"), href=""), "Circos Viewer",escape=F),
           tabPanel("Analysis",
                    sidebarLayout(
                      position = "left",
                      sidebarPanel(
                        width = 3,
                        h4("File Uploader", style="color: STEELBLUE"),
                        fileInput("csvfile", "File to upload",
                                  multiple = FALSE,
                                  accept = c("text/csv",
                                             "text/comma-separated-values,text/plain",
                                             ".csv", ".xlsx", ".xls")),
                        # Include clarifying text ----
                        helpText("Note: Maximum file size allowed for uploading is 300MB. If uploaded data is with .xlsx or .xls, separater can be any value, but please make sure data are located in Sheet1."),
                        
                        # Input: Checkbox if file has header ----
                        checkboxInput("header", "Header", TRUE),
                        
                        fluidRow(
                          # Input: Select separator ----
                          column(6, radioButtons("sep", "Separator",
                                                 choices = c(Comma = ",",
                                                             Semicolon = ";",
                                                             Tab = "\t",
                                                             Space = " "),
                                                 selected = ",")),
                          # Input: Select quotes ----
                          column(6, radioButtons("quote", "Quote",
                                                 choices = c(None = "",
                                                             "Double Quote" = '"',
                                                             "Single Quote" = "'"),
                                                 selected = '"'))
                        ),
                        # Horizontal line ----
                        tags$hr(),
                        actionButton("action1", "Confirm when Complete"),
                        conditionalPanel(condition = "input.action1",
                                         tags$br(),
                                         actionButton("action2", "Visualize Circos Plot", style="color: WHITE; background-color: DODGERBLUE")
                                         )
                      ),
                      mainPanel(
                        h2("Circos Viewer:", style="color: STEELBLUE; font-size: 22px"),
                        h2("An interactive tool for visualize data in circos plot", style="color: STEELBLUE; font-size: 20px; margin: 0px"),
                        
                        h4("Files:", style="color: STEELBLUE"),
                        htmlOutput("check1"),
                        tags$br(),
                        h4("Data Summary:", style="color: STEELBLUE"),
                        uiOutput("csv.summary.ui"),
                        
                        tags$head(
                          tags$script(HTML("(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
                                           m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
                                           })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');
                                           
                                           ga('create', 'UA-113406500-2', 'auto');
                                           ga('send', 'pageview');"))
                          ),
                        tags$head(tags$script(HTML("document.title = 'Circos Viewer';"))), # rename the title by JS
                        tags$head(tags$script('Shiny.addCustomMessageHandler("buttonCallbackHandler",
                                              function(typeMessage) {console.log(typeMessage)
                                              if(typeMessage == "tab2"){
                                              console.log("got here");
                                              $("a:contains(Visualization)").click();
                                              }
                                              if(typeMessage == "tab3"){
                                              $("a:contains(Survival Analysis)").click();
                                              }
                                              });

                                              ')),
                                               br(),
                                               br(),
                                               br()
                               ) # end of mainPanel
                         ) # end of sidebarLayout
                    
                    ),
           tabPanel("Visualization"),
           tabPanel("About")
)