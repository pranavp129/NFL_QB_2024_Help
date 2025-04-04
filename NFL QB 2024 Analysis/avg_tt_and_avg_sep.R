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
  select(week, player_gsis_id, player_display_name, team_abbr, avg_time_to_throw)

# get receiving stats
nextgen_receiving <- nflreadr::load_nextgen_stats(seasons = 2024, stat_type = "receiving")
colnames(nextgen_receiving)

# group receiving data by team and week
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
            weeks_played = n(),
            player_gsis_id = first(player_gsis_id))

# get team colors and combine
teams <- nflreadr::load_teams(current = TRUE) %>%
  select(team_abbr, team_color, team_color2) %>%
  mutate(team_abbr = recode(team_abbr, "LA" = "LAR"))  # Adjust LA to LAR for Rams

season_ngs_data <- season_ngs_data %>% 
  left_join(teams, "team_abbr")

# filter by number of games played
season_ngs_data <- season_ngs_data %>% 
  filter(weeks_played >= 3)

# plot (without epa)
ggplot(data = season_ngs_data, aes(x = season_avg_time_to_throw, y = season_avg_team_separation)) +
  geom_mean_lines(aes(x0 = season_avg_time_to_throw, y0 = season_avg_team_separation), 
                  linewidth = 0.8,
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

# load player stats for QB EPA
player_stats <- nflreadr::load_player_stats(seasons = 2024)
colnames(player_stats)

# get passing epa, normalize passing epa between 1-20
min_size = 1
max_size = 20
qb_epa_stats <- player_stats %>% 
  filter(position == "QB") %>% 
  group_by(player_display_name) %>% 
  summarise(player_gsis_id = first(player_id),
            total_pass_epa = sum(passing_epa, na.rm = TRUE)) %>% 
  mutate(normalized_epa = (total_pass_epa - min(total_pass_epa)) / 
           (max(total_pass_epa) - min(total_pass_epa)),
         # Adjusting the size range by adding a constant (e.g., 1) to ensure the minimum size is not zero
         normalized_epa_size = normalized_epa * (max_size - min_size) + min_size)

# sort data by normalized_epa_size so that larger points are printed first
season_ngs_data_with_epa <- season_ngs_data %>% 
  left_join(qb_epa_stats, "player_gsis_id") %>% 
  arrange(-normalized_epa_size)  # Sorting by EPA size

# plot data with passing epa as point size
ggplot(data = season_ngs_data_with_epa, aes(x = season_avg_time_to_throw, y = season_avg_team_separation)) +
  geom_mean_lines(aes(x0 = season_avg_time_to_throw, y0 = season_avg_team_separation), 
                  linewidth = 0.8,
                  color = "black", 
                  linetype = "dashed",
                  alpha = 0.5) +
  geom_point(shape = 21,
             fill = season_ngs_data_with_epa$team_color,
             color = season_ngs_data_with_epa$team_color2,
             size = season_ngs_data_with_epa$normalized_epa_size) +
  geom_text_repel(aes(label = player_display_name.x),
                  box.padding = 1.1,
                  arrow.padding = .5,
                  force = 10,
                  size = 4,
                  fontface = "bold") +
  scale_x_continuous(breaks = scales::pretty_breaks(n = 6),
                     labels = scales::label_comma()) +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 6),
                     labels = scales::label_comma()) +
  labs(x = "Average Time to Throw (seconds)",
       y = "Average Separation of Receivers (yards)",
       title = "Quarterback Performance: Time to Throw vs. Receiver Separation",
       subtitle = "Passing EPA Represented by Circle Size",
       caption = "Data: Next Gen Stats, NFLReadR\n*Min. 3 games played\nPranav Pitchala") +
  nfl_analytics_theme()
