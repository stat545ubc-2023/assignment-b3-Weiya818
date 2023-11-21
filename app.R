# load al libraries
library(shiny)
library(tidyverse)
library(DT)
library(datateachr)

# load the vancouver_trees dataset
trees_dataset <- datateachr::vancouver_trees

# define User In Interface for the application
ui <- fluidPage(
  titlePanel("Vancouver Trees Explorer App"),
  # define the layout of sidebar
  sidebarLayout(
    sidebarPanel(
      # a feature which contains an image at the top
      img(src = "forest.png", width = "420px", height = "300px"),

      # a feature that creates a dropdown menu for the user to select the tree species for histogram
      selectInput("species", "Select Histogram Tree Species:",
                  choices = unique(trees_dataset$species_name),
                  selected = unique(trees_dataset$species_name)[1]),

      # a feature that creates a dropdown menu for the user to select a numeric variable for histogram
      selectInput("variable", "Select Histogram Variable:",
                  choices = names(trees_dataset %>% select_if(is.numeric)),
                  selected = "height_range_id"),

      # a feature that provides users with a slider interface that allows
      # them to select a bin width within a specified range
      sliderInput("binwidth", "Select Histogram Bin Width:",
                  min = 1, max = 50, value = 1),

      # a feature that creates a dropdown menu for the user to select a numeric variable for x_axis of the scatterplot
      selectInput("x_variable", "Select Scatterplot x_axis Variable:",
                  choices = names(trees_dataset %>% select_if(is.numeric)),
                  selected = "height_range_id"),

      # a feature that creates a dropdown menu for the user to select a numeric variable for y_axis of the scatterplot
      selectInput("y_variable", "Select Scatterplot y_axis Variable:",
                  choices = names(trees_dataset %>% select_if(is.numeric)),
                  selected = "diameter"),

      # a feature allows users to download csv for selected data table
      downloadButton("downloadData", "Download Filtered Data"),

      # a feature allows users to select one or multiple tree species for data table
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
                 h4("Total Number of Trees of This Species:"),
                 textOutput("total_results")),
        tabPanel("Scatter Plot",
                 plotOutput("scatter_plot", height="600px")),
        tabPanel("Data Table",
                 h4("Selected Tree Species Data Table"),
                 DTOutput("data_table"))
      )
    )
  )
)

# Define server logic
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

    ggplot(data_filtered, aes(x = !!sym(input$variable))) +
      geom_histogram(binwidth = input$binwidth, fill = '#3cb371') +
      labs(x = input$variable,
           title = paste('Histogram of', input$variable, 'for', input$species)) +
      theme_bw()
  })

  # display the total number of trees
  output$total_results <- renderText({
    paste(nrow(filtered_data()), "trees")
  })

  # display the data table using DT packages
  output$data_table <- renderDT({
    datatable(selected_checkbox_data (), options = list(pageLength = 10))
  })

  # generate a scatter plot
  output$scatter_plot <- renderPlot({
    # filter out rows with missing values in x and y variables
    filtered_data <- filtered_data() %>%
      filter(!is.na(!!sym(input$x_variable)), !is.na(!!sym(input$y_variable)))

    ggplot(filtered_data, aes(x = !!sym(input$x_variable), y = !!sym(input$y_variable))) +
      geom_point() +
      labs(x = input$x_variable, y = input$y_variable,
           title = paste('Scatter Plot of', input$x_variable, 'vs', input$y_variable, 'for', input$species)) +
      theme_bw()
  })

  # allow user to download csv
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("filtered_data_", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(selected_checkbox_data(), file)
    }
  )
}

# Run the application
shinyApp(ui = ui, server = server)
