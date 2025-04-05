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
        avg_rating <= input$rating_selected[2]
      )
  })
  
  # create table based on filtered table
  output$table0 <- DT::renderDataTable({
    data <- filtered_books() %>%
      select(book_names, author_name, avg_rating, no_of_ratings, no_of_pages) %>%
      rename(
        "Book Name" = book_names,
        "Author" = author_name,
        "Avg Rating" = avg_rating,
        "Number of Ratings" = no_of_ratings,
        "Number of Pages" = no_of_pages
      )
    
    datatable(data, options = list(dom = 'tpi'), filter = list(position = "bottom")) %>%
      formatCurrency(columns = c("Number of Ratings", "Number of Pages"),
                     currency = "",
                     interval = 3,
                     mark = ".",
                     digits = 0)
  })
  
  # text on I'm Feeling Lucky tab
  output$lucky_text <- renderText({
    paste0(
      "<b>In this tab, a random book is selected from the filtered list based on your chosen number of pages and average rating. ",
      "Click the 'Re-select a Random Book' button to get a new recommendation!</b>"
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
    random_book <- random_book_data()  # Get the current random book
    
    # Get details about the random book
    cover_file <- random_book$image_name  # Image file name (e.g., 'book1_cover.png')
    book_name <- random_book$book_names   # Book name
    author_name <- random_book$author_name # Author name
    no_of_pages <- random_book$no_of_pages # Number of pages
    book_url <- random_book$book_urls      # URL for the book
    avg_rating <- random_book$avg_rating      # URL for the book
    
    # Create the UI to display image, book details, and the URL
    tagList(
      br(),
      br(),
      img(src = cover_file, height = "100px", width = "auto", align = "center"),
      br(),
      br(),
      strong("Book Name: "), book_name, br(),
      strong("Book Url: "), a(href = book_url, target = "_blank", book_url), br(),
      strong("Author: "), author_name, br(),
      strong("Number of Pages: "), no_of_pages, br(),
      strong("Average Rating: "), avg_rating, br()
    )
  })
  
  # Observe the "Re-select" button click event and update the random book
  observeEvent(input$reselect, {
    update_random_book()  # Update the random book when button is clicked
  })
}
