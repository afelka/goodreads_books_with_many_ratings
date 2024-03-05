library(ggplot2)
library(ggimage)
library(dplyr)
library(ggrepel)


goodreads_books_with_many_ratings <- read.csv("goodreads_books_with_many_ratings.csv")

goodreads_books_with_many_ratings_top_250 <- goodreads_books_with_many_ratings %>% arrange(desc(no_of_ratings)) %>%
                                             head(250)

most_rated_book <- goodreads_books_with_many_ratings_top_250 %>% slice(1)
highest_avg_rating <- goodreads_books_with_many_ratings_top_250 %>% arrange(desc(avg_rating)) %>% slice(1)
lowest_avg_rating <- goodreads_books_with_many_ratings_top_250 %>% arrange(avg_rating) %>% slice(1)
lowest_avg_rating_with_two_an_half_million_votes <- goodreads_books_with_many_ratings_top_250 %>% 
                                             filter(no_of_ratings > 2500000) %>%
                                             arrange(avg_rating) %>% slice(1)


# Create a ggplot2 plot with book covers as points
gg <- ggplot(goodreads_books_with_many_ratings_top_250, aes(x = avg_rating, y = no_of_ratings)) +
  geom_image(aes(image = img_src), size = 0.03) +  # Add book covers
  geom_text_repel(data = most_rated_book, aes(x = avg_rating, y = no_of_ratings, 
                                        label = paste0(book_names, "\nhas the highest number of ratings with\n",
                                                       scales::comma(no_of_ratings))),
            color = "red", size = 2.5 , vjust = 1.5) +
  geom_text_repel(data = lowest_avg_rating_with_two_an_half_million_votes, aes(x = avg_rating, y = no_of_ratings, 
                                        label = paste0(book_names, "\nhas the lowest avg.(",avg_rating ,
                                                       ") rating across books \nrwith min 2.5M ratings\n")),
            color = "blue", size = 2.5 , vjust = -0.5, hjust = 0.2) +
  geom_text_repel(data = highest_avg_rating, aes(x = avg_rating, y = no_of_ratings, 
                                          label = paste0(substr(book_names,1,24), "\nhas the highest avg.(",avg_rating ,
                                                      ")\nrating across most rated books \n")),
            color = "orange", size = 2 , vjust = -0.25, hjust = 0.7) +
  geom_text_repel(data = lowest_avg_rating, aes(x = avg_rating, y = no_of_ratings, 
                                           label = paste0(book_names, "\nhas the lowest avg.(",avg_rating ,
                                                          ")\nrating across most rated books \n")),
            color = "purple", size = 2 , vjust = -2.25, hjust = 0.7) +
  labs(title = "Number of Ratings vs Average Rating for the Books with Highest Number of Ratings",
       x = "Average Rating",
       y = "Number of Ratings") +
  scale_y_continuous(labels = scales::comma) +  
  theme_minimal()  

# Save the plot as an image file
ggsave( "goodreads_plot_with_images.png",plot = gg, bg="white")