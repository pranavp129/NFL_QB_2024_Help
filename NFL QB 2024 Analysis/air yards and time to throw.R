library(nflverse)
library(tidyverse)
library(ggrepel)

source("theme.R")

teams <- nflreadr::load_teams()

ngs_data_passing <- nflreadr::load_nextgen_stats(seasons = 2024,
                                                 stat_type = "passing") %>%
  filter(week == 0) %>%
  select(player_display_name, team_abbr,
         avg_time_to_throw, avg_completed_air_yards)

ngs_data_passing <- ngs_data_passing %>%
  left_join(teams, b = c("team_abbr" = "team_abbr"))

ggplot(data = ngs_data_passing, aes(x = avg_time_to_throw,
                                    y = avg_completed_air_yards)) +
  geom_hline(yintercept = mean(ngs_data_passing$avg_completed_air_yards),
             color = "black", size = 0.8, linetype = "dashed") +
  geom_vline(xintercept = mean(ngs_data_passing$avg_time_to_throw),
             color = "black", size = 0.8, linetype = "dashed") +
  geom_point(size = 3.5, color = ngs_data_passing$team_color) +
  scale_x_continuous(breaks = scales::pretty_breaks(),
                     labels = scales::comma_format()) +
  scale_y_continuous(breaks = scales::pretty_breaks(),
                     labels = scales::comma_format()) +
  geom_text_repel(aes(label = player_display_name),
                  family = "Roboto", fontface = "bold", size = 3.5) +
  nfl_analytics_theme() +
  xlab("Average Time to Throw") +
  ylab("Average Completed Air Yards") +
  labs(title = "Average Time to Throw vs. Average Air Yards",
       subtitle = "2024 Regular Season",
       caption = "*Data: Next Gen Stats*
       **Pranav Pitchala**")