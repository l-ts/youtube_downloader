library(shiny)
library(shinyjs)
library(shinyalert)
library(shinythemes)
library(DT)

source('global.R')

# Define UI for app that draws a histogram ----
ui <- fluidPage(
    theme = shinytheme("slate"),
    useShinyjs(),
    useShinyalert(),

    # App title ----
    titlePanel("YouTube DownLoader"),

    # Sidebar layout with input and output definitions ----
    sidebarLayout(

        # Sidebar panel for inputs ----
        sidebarPanel(
            textAreaInput(
                inputId = 'url_space',
                label = NULL,
                placeholder = 'Drag and drop your song here',
                height = '760px'
            ),


            actionButton('Download','Download')

        ),

        mainPanel(
            DT::dataTableOutput('songs_df')
        )
    ),
    tags$head(
        tags$style(
            HTML(
                '
                #songs_df table.dataTable tbody tr{
                    line-height: 60%;
                    color:#000000;
                }
                '
            )
        )
    )
)