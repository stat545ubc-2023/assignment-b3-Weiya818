# load all libraries
library(shiny)
library(tidyverse)
library(DT)
library(datateachr)
library(colourpicker)
library(shinyBS)
library(shinythemes)

# load the vancouver_trees dataset
trees_dataset <- datateachr::vancouver_trees

# define User Interface for the application
ui <- fluidPage(
  titlePanel("Vancouver Trees Explorer App"),

  # (b4) Feature 9: Use shinythemes to change the appearance of the App
  theme = shinytheme("spacelab"),
  # (b4) Feature 7: Added CSS to make the shiny app look nicer
  includeCSS("www/style.css"),
  # define the layout of sidebar
  sidebarLayout(
    sidebarPanel(
      # Feature 1: a feature which contains an image at the top
      img(src = "forest.png", width = "420px", height = "300px"),

      # Feature 2: a feature that creates a dropdown menu for the user to select the tree species for histogram
      selectInput("species", "Select Histogram Tree Species:",
                  choices = unique(trees_dataset$species_name),
                  selected = unique(trees_dataset$species_name)[1]),

      # a feature that creates a dropdown menu for the user to select a numeric variable for histogram
      selectInput("variable", "Select Histogram Variable:",
                  choices = names(trees_dataset %>% select_if(is.numeric)),
                  selected = "height_range_id"),

      # Feature 3: a feature that provides users with a slider interface that allows
      # them to select a bin width within a specified range
      sliderInput("binwidth", "Select Histogram Bin Width:",
                  min = 1, max = 50, value = 1),

      # (b4) Feature 8: a feature to allow the user decide on the colours of the bars in the histogram
      colourInput("histColor", "Choose Histogram Bar Color", value = "#3cb371"),

      # a feature that creates a dropdown menu for the user to select a numeric variable for x_axis of the scatterplot
      selectInput("x_variable", "Select Scatterplot x_axis Variable:",
                  choices = names(trees_dataset %>% select_if(is.numeric)),
                  selected = "height_range_id"),

      # a feature that creates a dropdown menu for the user to select a numeric variable for y_axis of the scatterplot
      selectInput("y_variable", "Select Scatterplot y_axis Variable:",
                  choices = names(trees_dataset %>% select_if(is.numeric)),
                  selected = "diameter"),

      # a feature to allow the user decide on the colours of the points in the scatter plot
      colourInput("scatterColor", "Choose Scatter Plot Point Color", value = "#013220"),

      # Feature 6: a feature allows users to select one or multiple tree species for data table
      checkboxGroupInput("selected_species", "Select Tree Species for Data Table:",
                         choices = unique(trees_dataset$species_name),
                         selected = unique(trees_dataset$species_name)[1],
                         inline = TRUE)
    ),
    mainPanel(
      tabsetPanel(
        # include three different tab panels which generate histograms, scatter plots and data tables respectively
        tabPanel("Histogram",
                 plotOutput("histogram", height="600px"),
                 # (b4) Feature 10: Show the number of results found whenever the filters change
                 h4("Total Number of Trees of This Species:"),

                 # Feature 5: a feature allows users to download the generated histogram as png file.
                 textOutput("total_results"), downloadButton("downloadHistogram", "Download Histogram")),
        tabPanel("Scatter Plot",
                 plotOutput("scatter_plot", height="600px"), downloadButton("downloadScatterPlot", "Download ScatterPlot")),
        tabPanel("Data Table",
                 h4("Selected Tree Species Data Table"),
                 DTOutput("data_table"),
                 downloadButton("downloadData", "Download Selected Data"))

      )
    )
  )
)

# server side logic
server <- function(input, output) {

  # a reactive expression for the filtered data
  filtered_data <- reactive({
    trees_dataset %>%
      filter(species_name == input$species)
  })

  # a reactive expression for the checkbox data
  selected_checkbox_data <- reactive({
    trees_dataset %>%
      filter(species_name %in% input$selected_species)
  })

  # generate a histogram
  output$histogram <- renderPlot({
    # filter out rows with missing values or inf values
    data_filtered <- filtered_data() %>%
      filter(!is.na(!!sym(input$variable)), !is.infinite(!!sym(input$variable)))
    # plot the histogram
    ggplot(data_filtered, aes(x = !!sym(input$variable))) +
      geom_histogram(binwidth = input$binwidth, fill = input$histColor) +
      labs(x = input$variable,
           title = paste('Histogram of', input$variable, 'for', input$species)) +
      theme_bw()
  })

  # display the total number of trees
  output$total_results <- renderText({
    paste(nrow(filtered_data()), "trees")
  })

  # Feature 7: display the data table using DT packages
  output$data_table <- renderDT({
    datatable(selected_checkbox_data (), options = list(pageLength = 10))
  })

  # generate a scatter plot
  output$scatter_plot <- renderPlot({
    # filter out rows with missing values in x and y variables
    filtered_data <- filtered_data() %>%
      filter(!is.na(!!sym(input$x_variable)), !is.na(!!sym(input$y_variable)))
    # plot the scatter plot
    ggplot(filtered_data, aes(x = !!sym(input$x_variable), y = !!sym(input$y_variable))) +
      geom_point(color = input$scatterColor) +
      labs(x = input$x_variable, y = input$y_variable,
           title = paste('Scatter Plot of', input$x_variable, 'vs', input$y_variable, 'for', input$species)) +
      theme_bw()
  })

  # download handler for histogram
  output$downloadHistogram <- downloadHandler(
    filename = function() {
      paste('histogram','.png', sep = '')
    },
    content = function(file) {
      # save the selected histogram
      ggsave(file, plot = {
        data_filtered <- filtered_data() %>%
          filter(!is.na(!!sym(input$variable)), !is.infinite(!!sym(input$variable)))

        ggplot(data_filtered, aes(x = !!sym(input$variable))) +
          geom_histogram(binwidth = input$binwidth, fill = input$histColor) +
          labs(x = input$variable,
               title = paste('Histogram of', input$variable, 'for', input$species)) +
          theme_bw()}, device = "png", width = 12, height =10 )
    }
  )

  # download handler for scatterplot
  output$downloadScatterPlot <- downloadHandler(
    filename = function() {
      paste('sactterplot','.png', sep = '')
    },
    content = function(file) {
      # save the selected scatterplot
      ggsave(file, plot = {
        filtered_data <- filtered_data() %>%
          filter(!is.na(!!sym(input$x_variable)), !is.na(!!sym(input$y_variable)))

        ggplot(filtered_data, aes(x = !!sym(input$x_variable), y = !!sym(input$y_variable))) +
          geom_point(color = input$scatterColor) +
          labs(x = input$x_variable, y = input$y_variable,
               title = paste('Scatter Plot of', input$x_variable, 'vs', input$y_variable, 'for', input$species)) +
          theme_bw()}, device = "png", width = 14, height =8 )
    }
  )

  # allow user to download csv
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("selected_data_s", ".csv", sep = "")
    },
    content = function(file) {
      write.csv(selected_checkbox_data(), file)
    }
  )
}

# run the app
shinyApp(ui, server)
