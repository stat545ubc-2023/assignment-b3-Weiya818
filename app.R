# Load libraries
library(shiny)
library(tidyverse)
library(DT)
library(datateachr)

# Load the dataset
trees_dataset <- datateachr::vancouver_trees

# Define UI for application
ui <- fluidPage(
  titlePanel("Vancouver Trees Explorer App"),
  sidebarLayout(
    sidebarPanel(
      img(src = "forest.png", width = "420px", height = "300px"),
      selectInput("species", "Select Histogram Tree Species:",
                  choices = unique(trees_dataset$species_name),
                  selected = unique(trees_dataset$species_name)[1]),
      selectInput("variable", "Select Histogram Variable:",
                  choices = names(trees_dataset %>% select_if(is.numeric)),
                  selected = "height_range_id"),
      sliderInput("binwidth", "Select Histogram Bin Width:",
                  min = 1, max = 50, value = 1),
      selectInput("x_variable", "Select Scatterplot x_axis Variable:",
                  choices = names(trees_dataset %>% select_if(is.numeric)),
                  selected = "height_range_id"),
      selectInput("y_variable", "Select Scatterplot y_axis Variable:",
                  choices = names(trees_dataset %>% select_if(is.numeric)),
                  selected = "diameter"),
      downloadButton("downloadData", "Download Filtered Data"),
      checkboxGroupInput("selected_species", "Select Tree Species for Data Table:",
                         choices = unique(trees_dataset$species_name),
                         selected = unique(trees_dataset$species_name)[1],
                         inline = TRUE)
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Histogram",
                 plotOutput("histogram", height="600px"),
                 h4("Total Number of Trees of This Species:"),
                 textOutput("total_results")),
        tabPanel("Scatter Plot",
                 plotOutput("scatter_plot")),
        tabPanel("Data Table",
                 h4("Selected Tree Species Data Table"),
                 DTOutput("data_table"))
      )
    )
  )
)

# Define server logic
server <- function(input, output) {

  # Reactive expression for the selected data
  filtered_data <- reactive({
    trees_dataset %>%
      filter(species_name == input$species)
  })

  selected_checkbox_data <- reactive({
    trees_dataset %>%
      filter(species_name %in% input$selected_species)
  })

  # Generate a histogram
  output$histogram <- renderPlot({
    data_filtered <- filtered_data() %>%
      filter(!is.na(!!sym(input$variable)), !is.infinite(!!sym(input$variable)))

    ggplot(data_filtered, aes(x = !!sym(input$variable))) +
      geom_histogram(binwidth = input$binwidth, fill = '#3cb371') +
      labs(x = input$variable,
           title = paste('Histogram of', input$variable, 'for', input$species)) +
      theme_bw()
  })

  # Display total number of results
  output$total_results <- renderText({
    paste(nrow(filtered_data()), "trees")
  })

  # Display data table with DT
  output$data_table <- renderDT({
    datatable(selected_checkbox_data (), options = list(pageLength = 10))
  })

  # Scatter Plot
  output$scatter_plot <- renderPlot({
    # Filter out rows with missing values in x and y variables
    filtered_data <- filtered_data() %>%
      filter(!is.na(!!sym(input$x_variable)), !is.na(!!sym(input$y_variable)))

    ggplot(filtered_data, aes(x = !!sym(input$x_variable), y = !!sym(input$y_variable))) +
      geom_point() +
      labs(x = input$x_variable, y = input$y_variable,
           title = paste('Scatter Plot of', input$x_variable, 'vs', input$y_variable, 'for', input$species)) +
      theme_bw()
  })


  # Allow user to download csv
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
