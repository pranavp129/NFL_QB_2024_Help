# libraries
library(nflverse)
library(tidyverse)
library(ggrepel)
library(ggpath)

source("theme.R")

# get passing stats
nextgen_passing <- nflreadr::load_nextgen_stats(seasons = 2024, stat_type = "passing")
colnames(nextgen_passing)

nextgen_passing_season <- nextgen_passing %>% 
  filter(week == 0) %>% 
  select(player_display_name, team_abbr, avg_time_to_throw)

# get receiving stats
nextgen_receiving <- nflreadr::load_nextgen_stats(seasons = 2024, stat_type = "receiving")
colnames(nextgen_receiving)

nextgen_receiving_season <- nextgen_receiving %>% 
  filter(week == 0) %>% 
  group_by(team_abbr) %>% 
  summarize(avg_team_separation = mean(avg_separation))

full_ngs_data <- nextgen_passing_season %>% 
  left_join(nextgen_receiving_season, "team_abbr")

# get team colors
teams <- nflreadr::load_teams(current = TRUE) %>%
  select(team_abbr, team_color, team_color2)

full_ngs_data <- full_ngs_data %>% 
  left_join(teams, "team_abbr")

# plot
ggplot(data = full_ngs_data, aes(x = avg_time_to_throw, y = avg_team_separation)) +
  geom_mean_lines(aes(x0 = avg_time_to_throw, y0 = avg_team_separation), 
                  size = 0.8,
                  color = "black", 
                  linetype = "dashed",
                  alpha = 0.5) +
  geom_point(shape = 21,
             fill = full_ngs_data$team_color,
             color = full_ngs_data$team_color2,
             size = 4.5) +
  geom_text_repel(aes(label = player_display_name),
                  box.padding = 0.45,
                  size = 3,
                  family = "Roboto",
                  fontface = "bold") +
  scale_x_continuous(breaks = scales::pretty_breaks(n = 6),
                     labels = scales::label_comma()) +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 6),
                     labels = scales::label_comma()) +
  labs(x = "Average Time to Throw",
       y = "Average Seperation of Recievers",
       title = "How Easy a Quarterback's Job was in 2024",
       subtitle = "Average Time to Throw vs. Average Seperation of Recievers",
       caption = "Data: Next Gen Stats
       *Pranav Pitchala*") +
  nfl_analytics_theme()
