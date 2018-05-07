library(shiny)
library(data.table)
library(DT)
library(openxlsx)
library(circlize)
library(ggplot2)

options(shiny.maxRequestSize=300*1024^2) # to the top of server.R would increase the limit to 300MB
options(shiny.sanitize.errors = FALSE)
options(stringsAsFactors = FALSE)

csv <- NULL
source("utils.R")
source("circos_plot.R")


function(input, output, session) {
  
  output$check1 <- renderText({'<img src="./images/check_no.png", style="width:30px">'})
  
  loadData.csv<- function(){
    if (is.null(input$csvfile)){
      return(NULL)
    }
    else{
        fileExtension <- getFileNameExtension(input$csvfile$datapath)
        if(fileExtension == "csv"){
          csv <<- read.csv(input$csvfile$datapath,
                            header = input$header,
                            sep = input$sep,
                            quote = input$quote)
          print("csv file Processed.")
        }
        else if(fileExtension == "txt"){
          data_temp = as.matrix(readLines(input$csvfile$datapath), sep = '\n')
          data_temp = strsplit(data_temp, split=input$sep)
          max.length <- max(sapply(data_temp, length))
          data_temp <- lapply(data_temp, function(v) { c(v, rep(NA, max.length-length(v)))})
          data_temp <- data.frame(do.call(rbind, data_temp))
          if(data_temp[dim(data_temp)[1],1] == "!series_matrix_table_end"){
            print("remove last row with \"!series_matrix_table_end\" ")
            data_temp = data_temp[-dim(data_temp)[1],]
          }
          csv <<- data_temp
          print("txt file Processed.")
        } else if(fileExtension == "xlsx" || fileExtension == "xls"){
          data_temp <- read.xlsx(input$csvfile$datapath, sheet = 1, startRow = 1, colNames = TRUE)
          if(data_temp[dim(data_temp)[1],1] == "!series_matrix_table_end"){
            print("remove last row with \"!series_matrix_table_end\" ")
            data_temp = data_temp[-dim(data_temp)[1],]
          }
          # data_temp <- print.data.frame(data.frame(data_temp), quote=FALSE)
          csv <<- data_temp
          print("xlsx / xls file Processed.")
        }
        
      }
    return(dim(csv))
  }
  observeEvent(loadData.csv(),{
    output$check1 <- renderText({'<img src="./images/check_yes.png", style="width:30px">'})
    output$csv.summary.ui <- renderUI({
      DT::dataTableOutput("csv.summary.datatable")
    })
    })
  
  
  observeEvent(input$action1,{
    if(!is.null(loadData.csv()) ){
      sendSweetAlert(session, title = "File Upload Success", text = NULL, type = "success",
                     btn_labels = "Ok", html = FALSE, closeOnClickOutside = TRUE)
      
      output$csv.summary.datatable <- DT::renderDataTable({
        csv
      }, selection="none", extensions = 'Responsive', options=list(searching=T, ordering=F))
    }
    else{
      sendSweetAlert(session, title = "Insufficient Input Data", text = "Please upload required files.", type = "error",
                     btn_labels = "Ok", html = FALSE, closeOnClickOutside = TRUE)
    }
  })
  
  observeEvent(input$action2,{
    if(!is.null(loadData.csv()) ){
      output$circos.plot.1 <- renderPlot({
        circosPlot(data = csv, hg.number = "hg19", myTitle = "Human Genome (hg19)")
      }, height = input$plot.height, width = input$plot.width)
      output$circos.plot.2 <- renderPlot({
        circosPlot(data = csv, hg.number = "hg38", myTitle = "Human Genome (hg38)")
      }, height = input$plot.height, width = input$plot.width)
      
      output$circos.plot.legend <- renderPlot({
        # Add a legend
        plot.new()
        legend("topleft",
               legend = c("CNA\t\tAMP", "CNA\t\tHOMDEL", "FUSION", "Inframe", "Missense", "Truncation",
                          "EXP mRNA\tUP", "EXP mRNA\tDOWN", "EXP Protein\tUP", "EXP Protein\tDOWN"), 
               col = c("darkgreen","red","pink","darkgreen","black","red",
                       "green","red","green","red"), 
               pch = c(8,8,95,16,16,16,24,25,15,14), 
               bty = "n", 
               pt.cex = 2, 
               cex = 1.2, 
               text.col = "black", 
               horiz = F , 
               inset = c(0.1, 0.1))
      })
      session$sendCustomMessage("buttonCallbackHandler", "tab2")
    }
    else{
      sendSweetAlert(session, title = "Insufficient Input Data", text = "Please upload required files.", type = "error",
                     btn_labels = "Ok", html = FALSE, closeOnClickOutside = TRUE)
    }
  })
  
  observeEvent(input$action3,{
    print("variable changes received.")
    if(!is.null(loadData.csv()) ){
      output$circos.plot.1 <- renderPlot({
        circosPlot(data = csv, hg.number = "hg19", myTitle = "Human Genome (hg19)",
                   font.scale = input$font.scale, symbol.size = input$symbol.size,
                   line.width = input$line.width,
                   plot.margin = input$plot.margin, line.color = input$color.picker)
      }, height = input$plot.height, width = input$plot.width)
      output$circos.plot.2 <- renderPlot({
        circosPlot(data = csv, hg.number = "hg38", myTitle = "Human Genome (hg38)",
                   font.scale = input$font.scale, symbol.size = input$symbol.size,
                   line.width = input$line.width,
                   plot.margin = input$plot.margin, line.color = input$color.picker)
      }, height = input$plot.height, width = input$plot.width)
    }
    else{
      sendSweetAlert(session, title = "Insufficient Input Data", text = "Please upload required files.", type = "error",
                     btn_labels = "Ok", html = FALSE, closeOnClickOutside = TRUE)
    }
  })
  
}