# Reflection

The final version of the dashboard managed to answer all research questions that we initially raised. By selecting target genres and desired year ranges, end users can understand trends and key features of certain types of movies from different dimensions.

### Current Implementations

Filters:

- Slider: year range
- Checklist: movie genres

Outputs:

- Bar chart: US revenue (box offices) for different movie genres
- Scatter plot: the relationship between IMDB ratings and duration
- Line chart: the trend of US revenue (box office)

### Accomplishments

- Instead of using overly professional graphics, the app displays 3 intuitive illustrations, such as scatter plot, bar chart and line chart. Therefore, massive statistical knowledge or extensive industry background is not necessarily required for using the app.
- The 3 graphs are tightly linked to each other as the app supports various interactivity. It provides flexibility to present different characteristics of each selected genre.
- The usage instructions are simple and intuitive.
- The app was deployed on Heroku. So, other users are welcome to use the app for their purpose by accessing the webserver.
- Each plot demonstrates different information of movies with minimal overlaps.


### Reflection on R Implementations and Future Improvements

- Based on the peer review comments, in order to better serve the needs for potential audiences, the app should provide a list of movies that are recommended based on users' preferences. If time permits, we would like to develop another tab for movie recommendations!
- R has more requirements and constraints on deployment to Heroku.
- The ggplot in R does not well support interactivity between graphs. We find it difficult to implement the same interactivity as what we facilitated in Python
- If time permits, we would like to look for a more updated data set for movies as our current data set only contains movies that were produced before 2016.
- Our data set is unbalanced, some genres (e.g. Black Comedy) only have a limited number of movies. So, our final result may not be comprehensive.
- The background colour and overall web aesthetic design could be refined.
- Our team only used several features in the data set. Perhaps, we can incorporate more features to generate more meaningful insights for movie enthusiasts.
- There is no instruction for using the interactivity on the app. A detailed usage instruction could be provided.
- For future development, we may consider adding a couple of advanced graphics as optional plots, which provide more information to different users.
- For now, the app only supports two filters. In the future, we may include more options, such as MPAA Ratings or Distributors.
- The app only presents the US Revenue as an indication of the box offices. To extend our user pool from North America to the international market, the amount of worldwide revenue could be added.





- Our team only used several features in the data set. Perhaps, we can incorporate more features to generate more meaningful insights for movie enthusiasts.
- There is no instruction for using the interactivity on the app. A detailed usage instruction could be provided.
- For future development, we may consider adding a couple of advanced graphics as optional plots, which provide more information to different users.
- For now, the app only supports two filters. In the future, we may include more options, such as MPAA Ratings or Distributors.
- The app only presents the US Revenue as an indication of the box offices. To extend our user pool from North America to the international market, the amount of worldwide revenue could be added.
