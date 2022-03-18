library(dash)
library(dashHtmlComponents)
library(dashCoreComponents)
library(ggplot2)
library(plotly)
library(dplyr)
library(tidyverse)

markdown_text <- "
Contributors of this dashboard: Adrianne Leung, Linhan Cai, Junrong Zhu, Zack Tang. 
The source code can be found [Here](https://github.com/UBC-MDS/movielover_r/blob/app-dev/app.R). 
Detailed information about wrangled data, dashboard purpose and how to contribution can be retrieved from Github 
[repository](https://github.com/UBC-MDS/movielover_r). The original dataset is from [Vega Dataset](https://github.com/vega/vega-datasets).
"
tips <-"
1. Hover over the scatter points to see detailed rating values and duration.
2. Hover over the bars to see detailed gross revenue (in millions USD) of the genre.
3. Hover over the lines to see detailed average revenue (in millions USD) of the genre.
4. Click and drag on the line plot or scatter plot to create a movable selection region.
5. Double click on the white area in the line plot or scatter plot to disregard the selected region.
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
              list(h1('Movie Lover'), div("An Interactive Movie Information Dashboard.")),
                style = list("border-width" = "0", "backgroundColor" = "#b1d0fc")
          ) # dbcCard
        ), # list
      ), # dbcRow
      htmlBr(),
      dbcRow(
        list(
          dbcCol(),
          dbcCol(),
          dbcCol(),
          dbcCol(),
          dbcCol(),
          dbcCol(),
          dbcCol(),
          dbcCol(),
          dbcCol(),
          dbcCol(
            list(
              dbcButton("Tips", id='popover-target', color='secondary', size="md"),
              dbcPopover(
                list(
                  dbcPopoverHeader('Plot interactions:'),
                  dbcPopoverBody(
                    dccMarkdown(tips)
                  )
                ),
                id='popover',
                target='popover-target',
                placement='bottom',
                trigger="click"
              )
            )
          )
        )
      ),
      dbcRow(
        list(
          div(
            style = list(width = '20%'),
          dbcCol(
            list(
            dbcCard(
              list(
              dbcCardHeader(
              htmlLabel('Movie Criterions', style = list("font-size" = 17))),
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
                div(
                  style = list(width = '40%'),
                dbcCol(
                  dccGraph(id='scatter-area')
                )
                ),
                div(
                  style = list(width = '60%'),
                dbcCol(
                  dccGraph(id='bar-area')
                  )
                )
                )
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
                 y = Major_Genre,
                 fill = Major_Genre,
                 text = paste("US Revenue: $", round(US_Revenue, digits = 2),
                              "<br>Major Genre: ", Major_Genre))) +
      geom_bar(stat = "identity") +
      scale_x_continuous(labels = function(x) format(x, big.mark = ",", scientific = FALSE)) +
      xlab ("Gross Revenue (in millions USD)") +
      ylab("Major genre") +
      ggtitle("Gross Revenue (box office) by Genre")
    bar <- bar + guides(fill = guide_legend(title = "Genres"))
    
    ggplotly(bar, tooltip = "text")
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
                 color = Major_Genre,
                 text = paste("Duration: ", Duration,
                              "<br>IMDB Rating:", IMDB_Rating,
                              "<br>Major Genre: ", Major_Genre),
                 group = 1)) +
      geom_point() +
      xlab ("IMDB Rating") +
      ylab("Duration (in mins)") +
      ggtitle("Duration Vs. IMDB Rating") +
      theme_bw()
    scatter <- scatter + theme(legend.position="none")
    
    ggplotly(scatter, tooltip = "text")
  }
)

app$callback(
  output('line-area', 'figure'),
  list(input('year_range', 'value'),
       input('genre_checklist', 'value')),
  function(year, genre) {
    line <- movie %>% 
      filter(Year >= year[1] & Year <= year[2], Major_Genre %in% genre) %>%
      group_by(Major_Genre, Year) %>%
      summarise(US_Revenue = mean(US_Revenue)) %>%
      ggplot(aes(x = Year, 
                 y = US_Revenue, 
                 color = Major_Genre,
                 text = paste("Year: ", Year,
                              "<br>US Revenue: $", round(US_Revenue, digits = 2),
                              "<br>Major Genre: ", Major_Genre), 
                 group=1)) +
      geom_line(stat = "identity") +
      geom_point(stat = "identity", shape = 'point') + 
      scale_x_continuous(breaks = scales::pretty_breaks(n = 10)) +
      xlab ("Year") +
      ylab("Average Revenue (in millions USD)") +
      ggtitle("Average Revenue (box office) by Genre") +
      theme_bw()
    line <- line + theme(legend.position="none")
    
    ggplotly(line, tooltip = "text")
  }
)

app$run_server(host = '0.0.0.0')