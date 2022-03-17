library(dash)
library(dashHtmlComponents)
library(dashCoreComponents)
library(ggplot2)
library(plotly)
library(dplyr)
library(tidyverse)

markdown_text <- "
Contributors of this dashboard: Adrianne Leung, Linhan Cai, Junrong Zhu, Zack Tang. 
The source code can be found [Here](https://github.com/UBC-MDS/movielover_py/blob/main/src/app.py). 
Detailed information about wrangled data, dashboard purpose and how to contribution can be retrieved from Github 
[repository](https://github.com/UBC-MDS/movielover_py). The original dataset is from [Vega Dataset](https://github.com/vega/vega-datasets).
"

app <- Dash$new(external_stylesheets = dbcThemes$BOOTSTRAP)

movie <- read.csv('data/clean/movies_clean_df.csv') %>% 
  setNames(c("Index", "Title", "Major_Genre","Duration","Year", "US_Revenue",
             "IMDB_Rating", "MPAA_Rating"))

genre <- unique(movie$Major_Genre)

default_genres <- c("Action", "Adventure", "Comedy", "Drama", "Horror", "Romantic Comedy")

app$layout(
  dbcContainer(
    list(
      dbcRow(
        list(
          dbcCard(
            dbcCardBody(
              list(h1('Movie Lover'), div("An Interactive Movie Information Dashboard.")),
              style = list("border-width" = "0", "backgroundColor" = "#b1d0fc")
            ) # dbcCardBody
          ) # dbcCard
        ), # list
      ), # dbcRow
      dbcRow(
        list(
          div(
            style = list(width = '20%'),
            dbcCol(
              list(
                dbcCard(
                  list(
                    dbcCardHeader(
                      h4('Movie Criterions')),
                    dbcCardBody(
                      list(
                        htmlBr(),
                        htmlP('Year range'),
                        dccRangeSlider(
                          id="year_range",
                          step = 1,
                          min = 1980,
                          max = 2016,
                          marks = list("1980"="1980", "2016"="2016"),
                          value = list(1990, 2005)
                        ),
                        htmlBr(),
                        htmlP('Select the movie genre'),
                        dccChecklist(
                          id="genre_checklist",                    
                          className="genre-container",
                          inputClassName="genre-input",
                          labelClassName="genre-label",
                          options=genre,                        
                          value=default_genres,
                          labelStyle=list("display" = "block", "margin-left" = "30px"),
                        ),
                        htmlBr(),
                        htmlP("About:"),
                        dccMarkdown(markdown_text)
                      )
                    )
                  )
                )
              ) # list
            ) # div
          ), # dbcCol
          div(
            style = list(width = '80%'),
            dbcCol(
              list(
                dbcRow(
                  list(
                    dbcCol(
                      dccGraph(id='scatter-area'),
                    ),
                    dbcCol(
                      dccGraph(id='bar-area'),
                    )
                  ),
                ),
                dbcRow(
                  dccGraph(id='line-area'),
                )
              )
            ) #div
          )
        )
      ) #list 2
    ) #dbcRow 2
  ) #dbcContainer
) #app$layout

app$callback(
  output('bar-area', 'figure'),
  list(input('year_range', 'value'),
       input('genre_checklist', 'value')),
  function(year, genre) {
    bar <- movie %>% 
      filter(Year >= year[1] & Year <= year[2], Major_Genre %in% genre) %>%
      group_by(Major_Genre) %>%
      summarise(US_Revenue = sum(US_Revenue)) %>%
      ggplot(aes(x = US_Revenue, 
                 y = reorder(Major_Genre, desc(Major_Genre)),
                 fill = Major_Genre)) +
      geom_bar(stat = "identity") +
      xlab ("Gross Revenue (in millions USD)") +
      ylab("Major genre") +
      ggtitle("Gross Revenue (box office) by Genre")
    bar <- bar + guides(fill=guide_legend(title="Genres"))
    
    ggplotly(bar)
  }
)   

app$callback(
  output('scatter-area', 'figure'),
  list(input('year_range', 'value'),
       input('genre_checklist', 'value')),
  function(year, genre) {
    scatter <- movie %>% 
      filter(Year >= year[1] & Year <= year[2], Major_Genre %in% genre) %>% 
      ggplot(aes(x = Duration, 
                 y = IMDB_Rating,
                 color = Major_Genre)) +
      geom_point() +
      xlab ("IMDB Rating") +
      ylab("Duration (in mins)") +
      ggtitle("Duration Vs. IMDB Rating") +
      ggthemes::scale_color_tableau() +
      theme_bw()
    scatter <- scatter + theme(legend.position="none")
    
    ggplotly(scatter)
  }
)

app$callback(
  output('line-area', 'figure'),
  list(input('year_range', 'value'),
       input('genre_checklist', 'value')),
  function(year, genre) {
    line <- movie %>% 
      filter(Year >= year[1] & Year <= year[2], Major_Genre %in% genre) %>% 
      ggplot(aes(x = Year, 
                 y = US_Revenue, 
                 color = Major_Genre)) +
      geom_line(stat = 'summary', fun = mean) +
      geom_point(stat = 'summary', fun = mean, shape = 'point') + 
      xlab ("Year") +
      ylab("Average Revenue (in millions USD)") +
      ggtitle("Average Revenue (box office) by Genre") +
      ggthemes::scale_color_tableau() +
      theme_bw()
    line <- line + theme(legend.position="none")
    
    ggplotly(line)
  }
)

app$run_server(debug = T)