#load packages
library(shiny)
library(dplyr)
library(ggplot2)
library(DT)
library(plotly)

data <- read.csv("goodreads_books_with_many_ratings.csv")

server <- function(input, output, session) {
  
  # Reactive subset based on slider input
  filtered_books <- reactive({
    req(input$pages_selected, input$rating_selected)
    
    data %>%
      filter(
        no_of_pages >= input$pages_selected[1],
        no_of_pages <= input$pages_selected[2],
        avg_rating >= input$rating_selected[1],
        avg_rating <= input$rating_selected[2],
        no_of_ratings >= input$no_rating_selected[1],
        no_of_ratings <= input$no_rating_selected[2],
        my_rating >= input$my_rating_selected[1],
        my_rating <= input$my_rating_selected[2]
      )
  })
  
  # create table based on filtered table
  output$table0 <- DT::renderDataTable({
    data <- filtered_books() %>%
      mutate(
        my_rating_display = ifelse(my_rating == 0, "Not Read", as.character(my_rating))
      ) %>%
      select(book_names, author_name, avg_rating, no_of_ratings, no_of_pages, my_rating_display) %>%
      rename(
        "Book Name" = book_names,
        "Author" = author_name,
        "Avg Rating" = avg_rating,
        "Number of Ratings" = no_of_ratings,
        "Number of Pages" = no_of_pages,
        "Erdem's Rating" = my_rating_display
      )
    
    datatable(data,  options = list(
        dom = 'tpi',
        columnDefs = list(
          list(className = 'dt-center', targets = "_all")
        )
    ), 
    filter = list(position = "bottom")
    )  %>%
      formatCurrency(columns = c("Number of Ratings", "Number of Pages"),
                     currency = "",
                     interval = 3,
                     mark = ".",
                     digits = 0)
  })
  
  # text on I'm Feeling Lucky tab
  output$lucky_text <- renderUI({
    HTML(
      paste0(
        "<b>In this tab, a random book is selected from the filtered list based on your chosen number of pages, average rating, number of ratings and Erdem's rating.</b><br><br>",
        "<b>Click the 'Re-select a Random Book' button to get a new recommendation!</b>"
      )
    )
  })
  
  # Reactive value to store the current random book details
  random_book_data <- reactiveVal()
  
  # Function to update random book details based on the filtered books
  update_random_book <- function() {
    # Ensure there are books available after filtering
    available_books <- filtered_books()
    if (nrow(available_books) > 0) {
      random_book <- sample_n(available_books, 1)
      random_book_data(random_book)  # Store the random book in reactive value
    }
  }
  
  # Initially update random book details
  observe({
    update_random_book()  # Update the random book when the app is initialized
  })
  
  # Render the random book cover details
  output$random_book_cover_details <- renderUI({
    random_book <- random_book_data()      # Get the current random book
    
    # Extract details
    cover_file   <- random_book$image_name
    book_name    <- random_book$book_names
    author_name  <- random_book$author_name
    no_of_pages  <- random_book$no_of_pages
    book_url     <- random_book$book_urls
    avg_rating   <- random_book$avg_rating
    my_rating    <- random_book$my_rating 
    
    # Convert my_rating: 0 → "Not Read", 1–5 → as‑is
    my_rating_display <- ifelse(my_rating == 0, "Not Read", as.character(my_rating))
    
    # Build the UI fragment
    tagList(
      br(), br(),
      img(src = cover_file, height = "100px", width = "auto", align = "center"),
      br(), br(),
      strong("Book Name: "),  book_name,          br(),
      strong("Book Url: "),   a(href = book_url, target = "_blank", book_url), br(),
      strong("Author: "),     author_name,        br(),
      strong("Number of Pages: "), no_of_pages,   br(),
      strong("Average Rating: "),   avg_rating,   br(),
      strong("Erdem's Rating: "),        my_rating_display, br() 
    )
  })
  
  # Observe the "Re-select" button click event and update the random book
  observeEvent(input$reselect, {
    update_random_book()  # Update the random book when button is clicked
  })
}
