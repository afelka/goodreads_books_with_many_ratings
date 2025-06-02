# -*- coding: utf-8 -*-
"""
Created on Tue Mar  5 09:10:24 2024

@author: ozbek
"""

from selenium import webdriver
from selenium.webdriver.common.by import By
import re
import pandas as pd
import requests
import time

#start chrome driver
driver = webdriver.Chrome()

#sign in to goodreads
driver.get("https://www.goodreads.com/user/sign_in")

sign_in_with_email = driver.find_element("css selector", ".authPortalSignInButton")
sign_in_with_email.click()

# Find elements by CSS selector
user_email = driver.find_element("css selector", "#ap_email")
user_password = driver.find_element("css selector", "#ap_password")

# Use the send_keys method to input data
email_input = input("Enter your email: ")
password_input = input("Enter your password: ")

user_email.send_keys(email_input)
user_password.send_keys(password_input)

sign_in_submit = driver.find_element("css selector", "#signInSubmit")
sign_in_submit.click()

# List of URLs (books with at least 500K Ratings)
urls = ["https://www.goodreads.com/list/show/35080", 
        "https://www.goodreads.com/list/show/35080.One_Million_Ratings_?page=2",
        "https://www.goodreads.com/list/show/35177",
        "https://www.goodreads.com/list/show/35177.Half_a_million_ratings_to_a_million_ratings?page=2",
        "https://www.goodreads.com/list/show/35177.Half_a_million_ratings_to_a_million_ratings?page=3",
        "https://www.goodreads.com/list/show/35177.Half_a_million_ratings_to_a_million_ratings?page=4",
        "https://www.goodreads.com/list/show/36647",
        "https://www.goodreads.com/list/show/36647.Books_with_ratings_from_200_000_to_500_000?page=2",
        "https://www.goodreads.com/list/show/36647.Books_with_ratings_from_200_000_to_500_000?page=3",
        "https://www.goodreads.com/list/show/36647.Books_with_ratings_from_200_000_to_500_000?page=4",
        "https://www.goodreads.com/list/show/36647.Books_with_ratings_from_200_000_to_500_000?page=5",
        "https://www.goodreads.com/list/show/36647.Books_with_ratings_from_200_000_to_500_000?page=6",
        "https://www.goodreads.com/list/show/36647.Books_with_ratings_from_200_000_to_500_000?page=7",
        "https://www.goodreads.com/list/show/36647.Books_with_ratings_from_200_000_to_500_000?page=8",
        "https://www.goodreads.com/list/show/36647.Books_with_ratings_from_200_000_to_500_000?page=9"
       ]

# Create an empty DataFrame
goodreads_list = pd.DataFrame(columns=['book_names', 'book_urls',
                                       'author_name', 'avg_rating',
                                       'no_of_ratings',
                                       'img_src'])

# Create a function to extract numeric values from text
def extract_numeric(text):
    return re.sub(r'[^0-9.]', '', text) if text else None

# Iterate through each URL in the list
for my_url in urls:
    # Navigate to the URL
    driver.get(my_url)

    # Find all matching elements with the specified XPath for each data attribute
    web_elements1 = driver.find_elements(By.XPATH, '//a[@class="bookTitle"]//span[@itemprop="name"]')
    book_names = [elem.text for elem in web_elements1]

    web_elements2 = driver.find_elements(By.XPATH, '//div[@class="js-tooltipTrigger tooltipTrigger"]//a')
    book_urls = [elem.get_attribute("href") for elem in web_elements2]

    web_elements3 = driver.find_elements(By.XPATH, '//a[@class="authorName"]//span')
    author_name = [elem.text for elem in web_elements3]

    web_elements4 = driver.find_elements(By.XPATH, '//span[@class="minirating"]')
    avg_rating_and_no_of_ratings = [elem.text for elem in web_elements4]

    # Lists to store extracted values
    avg_rating = []
    no_of_ratings = []

    # Process each text in the list
    for text in avg_rating_and_no_of_ratings:
        # Remove non-numeric characters using a regular expression
        cleaned_text = re.sub(r'[^0-9.,—]', '', text)

        # Split the cleaned text by a dash
        split_values = cleaned_text.split('—')

        # If there are two values after splitting, assign them to avg_rating and num_ratings
        if len(split_values) == 2:
            avg_rating_temp, no_of_ratings_temp = map(str.strip, split_values)

            # Remove commas from the number of ratings and convert it to an integer
            no_of_ratings_temp = int(no_of_ratings_temp.replace(',', ''))

            avg_rating.append(avg_rating_temp)
            no_of_ratings.append(no_of_ratings_temp)

    web_elements5 = driver.find_elements(By.XPATH, '//img[@class="bookCover"]')
    img_src = [elem.get_attribute("src") for elem in web_elements5]

    # Create a temporary DataFrame
    temp_list = pd.DataFrame({
        'book_names': book_names,
        'book_urls': book_urls,
        'author_name': author_name,
        'avg_rating': avg_rating,
        'no_of_ratings': no_of_ratings,
        'img_src': img_src
    })

    print(f"{my_url} finished")
    time.sleep(2)

    # Concatenate the temporary DataFrame with the main DataFrame
    goodreads_list = pd.concat([goodreads_list, temp_list], ignore_index=True)


for i in range(len(goodreads_list)):
    book_url = goodreads_list.iloc[i]['book_urls'] 
    driver.get(book_url)

    web_elements6 = driver.find_elements(By.XPATH, '//div[@class="FeaturedDetails"]//p[@data-testid="pagesFormat"]')
    if web_elements6:
        page_text = web_elements6[0].text  # e.g., "352 pages"
        try:
            page_count = int(re.search(r'\d+', page_text).group())
        except (AttributeError, ValueError):
            page_count = None
    else:
        page_count = None

    print(f"{book_url} finished")
    time.sleep(1)    

    goodreads_list.loc[i, 'no_of_pages'] = page_count
    
    
#download book covers 
for i in range(len(goodreads_list)):
    image_url = goodreads_list.iloc[i, 5]  

    image_name = f"cover_{i + 1}.png"
    goodreads_list.loc[i, 'image_name'] = image_name

    response = requests.get(image_url)
    
    with open(image_name, 'wb') as file:
        file.write(response.content)

    print(f"{image_name} finished")
    time.sleep(1) 
        
goodreads_list.to_csv("goodreads_books_with_many_ratings.csv", index=False)

driver.quit()