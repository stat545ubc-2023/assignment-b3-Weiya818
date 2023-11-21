# Vancouver Trees Explorer App

## App and Dataset Descriptions

The Vancouver Trees Explorer App allows users to explore and visualize the `vancouver_trees` dataset in various formats. To access the dataset, users need to install the `datateachr` package if they haven't done so already through `install.packages("datateachr")`. More detailed information about the dataset can be found in the [datateachr documentation](https://rdrr.io/github/UBC-MDS/datateachr/).

## Features Descriptions

The Vancouver Trees Explorer App offers several interesting features designed for a better user experience!

**Dropdown Menu**
- This is a feature that creates a dropdown menu for the user to select the tree species for the histogram or the variable of the x and y axis for the scatter plot.

**Slider Interface**
- This is a feature that provides users with a slider interface that allows them to select a bin width within a specified range for the histogram.

**Data Table**
- View detailed information about selected tree species, utilizing a dynamic data table that updates based on user selections.

**Visual Enhancements**
- Include an image of the forest at the top of the sidebar for a visually appealing interface.

**Checkbox For Multiple Species**
- Enables users to select one or multiple tree species simultaneously using checkboxes for the data table.
- Enhances flexibility for exploring data across different species.

**Download Feature**
- Download buttons are provided, allowing users to download the generated histogram and scatterplot as a PNG file or the generated data table as a CSV file for further analysis.

## Functionality Descriptions

**Histogram**
- Users can generate histograms for different tree species and numeric variables.
- Users can also adjust the bin width for a customized histogram.

**Scatter Plot**
- Explore relationships between two selected numeric variables using scatter plots.

**Data Table**
- View detailed information about selected tree species, utilizing a dynamic data table that updates based on user selections.

## Files in the Directory

**README.md**
- This is the current file, which contains the app and dataset descriptions, feature descriptions, files in the directory, and link to Shiny App.

**app.R**
- This is the R code file for the App.

**rsconnect**
- This is the file showing my App has already been deployed online in shinyapps.io.

**www**
- This folder contains the image file I included in the App.

## Shiny App Link

The App has already been deployed online on shinyapps.io.
You can access the App through [Vancouver_Trees_Explorer](https://weiyazhu.shinyapps.io/assignment-b3-weiya818/)

