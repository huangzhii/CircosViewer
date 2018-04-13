# 04/12/2018 Zhi Huang
library(shinyWidgets)
library(colourpicker)

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
                        p('If you want a sample data file to upload,',
                          'you can first download the sample',
                          a(href =  'MarkData.xlsx', 'MarkData.xlsx'),
                          'file, and then try uploading it'),
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
           tabPanel("Visualization",
                    sidebarLayout(
                      position = "left",
                      sidebarPanel(
                        width = 3,
                        h4("Change Plot Size", style="color: STEELBLUE"),
                        sliderInput(inputId="plot.width", label="Plot Width:", min=200, max=2000, value=800),
                        sliderInput(inputId="plot.height", label="Plot Height:", min=200, max=2000, value=800),
                        fluidRow(
                          column(6, numericInput(inputId="font.scale", label="Font Scale:", value = 1, min = 0.2, max=10, step = 0.1)),
                          column(6, numericInput(inputId="line.width", label="Line Width:", value = 5, min = 1, max=100, step = 1))
                        ),
                        colourInput(inputId="color.picker",label="Choose Line Color:",value="pinkW",
                                    showColour = "both",palette = "square"),
                        actionButton("action3", "Refresh", style="color: WHITE; background-color: DODGERBLUE")
                        
                        
                      ),
                      mainPanel(
                        h2("hg19:", style="color: STEELBLUE; font-size: 22px"),
                        plotOutput("circos.plot.1", width = "100%", height = "100%"),
                        h2("hg38:", style="color: STEELBLUE; font-size: 22px"),
                        plotOutput("circos.plot.2", width = "100%", height = "100%"),
                        h2("Legend:", style="color: STEELBLUE; font-size: 22px"),
                        plotOutput("circos.plot.legend", width = "400px", height = "400px")
                      ) # end of mainPanel
                    ) # end of sidebarLayout
                    ),
           tabPanel("About",
                    h3("About Us", style="color: STEELBLUE; padding-bottom: 20px"),
                    tags$div(
                      tags$img(src='images/IUSM2.png',
                               height="100",
                               alt="TSUNAMI", class="center", style="padding: 30px"),
                      tags$img(src='images/regenstrief.png',
                               height="100",
                               alt="TSUNAMI", class="center", style="padding: 30px"),
                      style="text-align: center; padding: 20px"
                    ),
                    h4("Our Other Softwares", style="color: STEELBLUE; padding-bottom: 20px"),
                    tags$div(
                      a(tags$img(src='images/tsunami_logo.png',
                                 height="45",
                                 alt="TSUNAMI", class="center", style="padding: 5px"), href="https://apps.medgen.iupui.edu/rsc/tsunami/", target="_blank"),
                      br(),a("TSUNAMI: Translational Bioinformatics Tool SUite for Network Analysis and MIning",
                             href="https://apps.medgen.iupui.edu/rsc/tsunami/", target="_blank"),
                      br(),br(),
                      a(tags$img(src='images/lmQCM_logo.png',
                                 height="60",
                                 alt="lmQCM", class="center", style="padding: 5px"), href="https://CRAN.R-project.org/package=lmQCM", target="_blank"),
                      br(),a("R package: lmQCM", href="https://CRAN.R-project.org/package=lmQCM", target="_blank"),
                      br(),br(),
                      a(tags$img(src='images/annoPeak_logo.png',
                                 height="40",
                                 alt="annoPeak", class="center", style="padding: 5px"), href="https://apps.medgen.iupui.edu/rsc/content/19/", target="_blank"),
                      br(),a("annoPeakR: a web-tool to annotate, visualize and compare peak sets from ChIP-seq/ChIP-exo", href="https://apps.medgen.iupui.edu/rsc/content/19/", target="_blank"),
                      style="text-align: center; padding: 5px"
                    ),
                    br(),
                    tags$div(
                      tags$img(src='images/iGenomicsR_logo2.png',
                               height="40",
                               alt="iGenomicsR", class="center", style="padding: 5px"),
                      br(),"Coming Soon",
                      br(),br(),
                      tags$img(src='images/iGPSe_logo.png',
                               height="50",
                               alt="iGPSe", class="center", style="padding: 5px"),
                      br(),"Coming Soon",
                      style="text-align: center; padding: 5px"
                    ),
                    h4("Development Team", style="color: STEELBLUE; padding-bottom: 20px"),
                    h5("Prof. Kun Huang's Laboratory", style="color: STEELBLUE"),
                    tags$ul(
                      tags$li("Zhi Huang"),
                      tags$li("Zhi Han"),
                      tags$li("Jie Zhang"),
                      tags$li("Kun Huang")
                    ),
                    h4("Publications", style="color: STEELBLUE; padding-bottom: 20px"),
                    tags$ul(
                      tags$li("-")
                    )
                  ),
           tags$div(
             p(a(img(src="images/logo.png",
                     height = 18,
                     style = "margin:-2px 0px; padding-bottom: 0px"), href=""),
               a("Circos Viewer", href=""), "Version v1.0 | ", a("IUSM",href="https://medicine.iu.edu/", target="_blank"), " | ", a("RI",href="http://www.regenstrief.org/", target="_blank"), style="color: grey; font-size: 12px"), 
             p("Questions and feedback: zhihuan@iu.edu | ", a("Report Issue", href="zhihuan@iu.edu", target="_blank"), " | ", a("Github", href="", target="_blank"), style="color: grey; font-size: 12px"),
             style="text-align: center; padding-top: 40px"
           )
)