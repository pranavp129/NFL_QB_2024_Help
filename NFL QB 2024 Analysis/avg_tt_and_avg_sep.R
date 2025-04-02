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
  filter(week != 0) %>% 
  select(week, player_display_name, team_abbr, avg_time_to_throw)

# get receiving stats
nextgen_receiving <- nflreadr::load_nextgen_stats(seasons = 2024, stat_type = "receiving")
colnames(nextgen_receiving)

nextgen_receiving_season <- nextgen_receiving %>% 
  filter(week != 0) %>% 
  group_by(team_abbr, week) %>% 
  summarize(avg_team_separation = mean(avg_separation))

# combine data
combined_ngs_data <- nextgen_passing_season %>% 
  left_join(nextgen_receiving_season, by = c("team_abbr", "week"))

# collect season data
season_ngs_data <- combined_ngs_data %>% 
  group_by(player_display_name, team_abbr) %>% 
  summarise(season_avg_time_to_throw = mean(avg_time_to_throw, na.rm = TRUE),
            season_avg_team_separation = mean(avg_team_separation, na.rm = TRUE),
            weeks_played = n())

# get team colors and combine
teams <- nflreadr::load_teams(current = TRUE) %>%
  select(team_abbr, team_color, team_color2)

season_ngs_data <- season_ngs_data %>% 
  left_join(teams, "team_abbr")

# filter by number of games played
season_ngs_data <- season_ngs_data %>% 
  filter(weeks_played >= 3)

# plot
ggplot(data = season_ngs_data, aes(x = season_avg_time_to_throw, y = season_avg_team_separation)) +
  geom_mean_lines(aes(x0 = season_avg_time_to_throw, y0 = season_avg_team_separation), 
                  size = 0.8,
                  color = "black", 
                  linetype = "dashed",
                  alpha = 0.5) +
  geom_point(shape = 21,
             fill = season_ngs_data$team_color,
             color = season_ngs_data$team_color2,
             size = 6) +
  geom_text_repel(aes(label = player_display_name),
                  box.padding = 0.6,
                  size = 3,
                  family = "Roboto",
                  fontface = "bold") +
  scale_x_continuous(breaks = scales::pretty_breaks(n = 6),
                     labels = scales::label_comma()) +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 6),
                     labels = scales::label_comma()) +
  labs(x = "Average Time to Throw (seconds)",
       y = "Average Separation of Receivers (yards)",
       title = "How Easy a Quarterback's Job was in 2024",
       subtitle = "Average Time to Throw vs. Average Separation of Receivers",
       caption = "Data: Next Gen Stats, NFLReadR\n*Min. 3 games played\nPranav Pitchala") +
  nfl_analytics_theme()
