## ---- final-data-preparation ----
library(readr)
library(tidyverse)
library(dplyr)

# Read cleaned datasets from EDA report 
elections <- read_csv("data/1976-2024-president-clean.csv")
polls_2012 <- read_csv("data/state_polls_2012_clean.csv")
polls_2016 <- read_csv("data/state_polls_2016_clean.csv")


# Prepare 2012 polling data 
# Convert observations into one row per poll 
polls_2012_wide <- polls_2012 |>
  filter(candidate %in% c("Obama", "Romney")) |> 
  pivot_wider(names_from = candidate, values_from = support) |>
# New column with election year 
  mutate(year = 2012) |> 
# New column with poll margin (Dem - Rep)
  mutate(margin_poll = Obama - Romney)

# Prepare 2016 polling data 
# Convert observations into one row per poll 
polls_2016_wide <- polls_2016 |>
  filter(candidate %in% c("Clinton", "Trump")) |> 
  pivot_wider(names_from = candidate, values_from = support) |>
# New column with election year 
  mutate(year = 2016) |> 
# New column with poll margin (Dem - Rep)
  mutate(margin_poll = Clinton - Trump)

# Combine both election year polling data 
polls_2012_2016 <- bind_rows(polls_2012_wide, polls_2016_wide) |> 
  # Keep columns necessary for modelling 
  select(year, state, poll_id, pollster, end_date, start_date, mode, sample_size, margin_poll)

# Check number of polls for each year after combining datasets 
polls_2012_2016 |> 
  count(year) 

# Prepare election results 
# Keep election results for only 2012 and 2016, Dem and Rep parties 
margin_elections <- elections |> 
  filter(year %in% c(2012, 2016)) |> 
  # Sum votes across all Rep candidate records and then across all Dem candidate records 
  group_by(year, state) |> 
  summarise(
    votes_rep = sum(candidatevotes[party_simplified == "REPUBLICAN"], 
    na.rm = TRUE), 
    votes_dem = sum(candidatevotes[party_simplified == "DEMOCRAT"], 
    na.rm = TRUE), 
  # Count total votes in each state for each election year 
  votes_total = first(totalvotes), 
  .groups = "drop") |> 
    # Calculate election Dem-Rep vote margin as percentage points 
    mutate(margin_actual = 100*(votes_dem - votes_rep)/votes_total) 
  
  # Create one dataset containing poll and election results 
  # Join polling votes with election outcomes 
  polls_and_elections <- polls_2012_2016 |>
    left_join(margin_elections |> select(year, state, margin_actual),
              by = c("year", "state"))
  # Check if any polls had no matching election results 
  sum(is.na(polls_and_elections$margin_actual))
    
# Prepare regression variables for models 
  model_data <- polls_and_elections |> 
    # Convert polling start and end dates into Date format 
    mutate(start_date = as.Date(start_date), 
           end_date = as.Date(end_date)) |> 
    # Add column for election date for the corresponding year 
    mutate(election_date = as.Date(if_else(year == 2016, "2016-11-08", "2012-11-06"))) |> 
    # Create column with number of days between poll and election 
    mutate(days_prior = as.numeric(as.numeric(election_date - end_date))) |> 
    # Create column with absolute polling error 
    mutate(abs_error = abs(margin_poll - margin_actual)) |> 
    # Create column to calculate logarithm of sample size 
    mutate(sample_size_log = if_else(sample_size > 0 & !is.na(sample_size),
                                     log(sample_size), 
                                     NA_real_)) |> 
    # Election year to be treated as a cateogorical variable for modelling purposes 
    mutate(year = factor(year)) |> 
    # Polling mode to be treated as a categorical variable for modelling purposes 
    mutate(mode = factor(mode)) 
  
  # Check model dataset 
  # Check: all polls have distinct state-year-poll ID 
  stopifnot(!anyDuplicated(model_data[c("year", "state", "poll_id")]))
  # Check: all polls occur before Election day 
  stopifnot(all(model_data$days_prior >= 0, na.rm = TRUE))
  # Check: missing values in variables 
  model_data |> 
    summarise(
      error_miss = sum(is.na(abs_error)), 
      year_miss = sum(is.na(year)), 
      mode_miss = sum(is.na(mode)), 
      sample_miss = sum(is.na(sample_size_log)), 
      days_miss = sum(is.na(days_prior))
    )
  # Understand distribution of polling modes 
  model_data |> 
    count(year, mode)
  
  # Construct final dataset for models 
  # Keep observations with no missing values (remove observations with missing sample size)
  final_model_data <- model_data |> 
    filter(!is.na(sample_size_log))
  # Check final number of polls for each year
  final_model_data |> 
    count(year)
  # Glimpse of final model dataset 
  glimpse(final_model_data)
  # Summary of means for main numerical variables 
  final_model_data |> 
    summarise(
      n = n(), 
      err_mean = mean(abs_error), 
      err_median = median(abs_error), 
      days_mean = mean(days_prior), 
      sample_mean = mean(sample_size))
  
  # Save dataset for regressional analysis in data folder 
  write_csv(final_model_data, "data/final_model_data.csv")
  