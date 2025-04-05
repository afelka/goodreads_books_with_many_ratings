#load packages
library(shiny)
library(dplyr)
library(ggplot2)
library(DT)
library(plotly)

#read data
data <- read.csv("goodreads_books_with_many_ratings.csv")

#design shiny app: 
shinyUI(fluidPage(
  
  titlePanel("Books with over 500.000 Goodreads Reviews"),
  
  # create slider inputs
  wellPanel(
    sliderInput("pages_selected", "Select Number of Pages",
                min = floor(min(data$no_of_pages, na.rm = TRUE) / 10) * 10,
                max = ceiling(max(data$no_of_pages, na.rm = TRUE) / 10) * 10,
                value = c(floor(min(data$no_of_pages, na.rm = TRUE) / 10) * 10,
                          ceiling(max(data$no_of_pages, na.rm = TRUE) / 10) * 10),
                step = 10),
    
    sliderInput("rating_selected", "Select Average Rating",
                min = 1,
                max = 5,
                value = c(1, 5),
                step = 0.2)
  ),
  
  #create panels 
  mainPanel(
    tabsetPanel(type = "tabs",
                tabPanel("List of Books", DT::dataTableOutput("table0")),
                tabPanel("I'm Feeling Lucky", 
                         # Explanatory text
                         br(),
                         htmlOutput("lucky_text"),
                         uiOutput("random_book_cover_details"),
                         br(),
                         br(),
                         actionButton("reselect", "Re-select a Random Book")  # Button to re-select a book
                )
    )
  ),
  
  tags$footer(
    style = "text-align: center; padding: 10px; background-color: #f5f5f5;",
    "Developed by: Erdem Emin Akcay | Email: erdememin@gmail.com"
  )
)
)

