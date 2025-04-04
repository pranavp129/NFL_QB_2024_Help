## NFL QB 2024 Analysis

### Overview
This project analyzes NFL quarterback data from the 2024 season using Next Gen Stats. The primary goal is to visualize QB performance metrics, focusing on:
- Average Time to Throw vs. Average Separation of Receivers, incorporating Passing EPA to provide insights into quarterback performance
- Average Time to Throw vs. Average Completed Air Yards

### Project Structure
- **Scripts:** Located in the folder `NFL QB 2024 analysis`.
  - **Script 1:** Examines the relationship between average time to throw and average separation of receivers, with point size representing passing EPA to add a performance dimension.
  - **Script 2:** Analyzes the relationship between average time to throw and average completed air yards.
- **Data Visuals:** All generated plots are saved in the `Data Visuals` folder.

### Libraries Used
- `nflverse`
- `tidyverse`
- `ggrepel`
- Custom theme loaded from `theme.R`

### Usage
To run the scripts, ensure that you have installed the necessary libraries. Load the custom theme using `source("theme.R")` before executing the scripts.

### Visualizations
The generated plots illustrate key metrics for quarterbacks from the 2024 NFL season. They provide insights into how QBs performed based on time to throw and either separation of receivers or completed air yards.

### Author
Pranav Pitchala

### Data Source
Next Gen Stats

