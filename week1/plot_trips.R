########################################
# load libraries
########################################

# load some packages that we'll need
library(tidyverse)
library(scales)

# be picky about white backgrounds on our plots
theme_set(theme_bw())

# load RData file output by load_trips.R
load('./week1/trips.RData')


########################################
# plot trip data
########################################

# (compare a histogram vs. a density plot)
ggplot(trips, aes(x = tripduration)) +
    geom_histogram(bins = 30) + scale_x_log10(label = comma)

ggplot(trips, aes(x=tripduration)) + geom_density(fill = "grey") + scale_x_log10(label = comma)

# plot the distribution of trip times by rider type indicated using color and fill (compare a histogram vs. a density plot)
ggplot(trips, aes(x = tripduration, fill = gender)) +
    geom_histogram(bins = 30) + scale_x_log10(label = comma)

ggplot(trips, aes(x=tripduration, fill = gender)) + geom_density() + scale_x_log10(label = comma)

# plot the total number of trips on each day in the dataset
trips |> mutate(date = as_date(starttime))|> ggplot(aes(x = date)) + geom_histogram()
# plot the total number of trips (on the y axis) by age (on the x axis) and gender (indicated with color)
trips |> group_by(birth_year) |> ggplot(aes(x = year(as_date(starttime)) - birth_year, fill = gender)) + geom_histogram() # nolint: line_length_linter.
# plot the ratio of male to female trip (on the y axis) by age (on the x axis)
trips |> group_by(birth_year) |> ggplot(aes(x = year(as_date(starttime)) - birth_year, fill = gender)) + geom_histogram() # nolint: line_length_linter.
# hint: use the pivot_wider() function to reshape things to make it easier to compute this ratio
# (you can skip this and come back to it tomorrow if we haven't covered pivot_wider() yet)

########################################
# plot weather data
########################################
# plot the minimum temperature (on the y axis) over each day (on the x axis)

# plot the minimum temperature and maximum temperature (on the y axis, with different colors) over each day (on the x axis)
# hint: try using the pivot_longer() function for this to reshape things before plotting
# (you can skip this and come back to it tomorrow if we haven't covered reshaping data yet)

########################################
# plot trip and weather data
########################################

# join trips and weather
trips_with_weather <- inner_join(trips, weather, by="ymd")
trips_with_weather |> head(n=30) |> View()
# plot the number of trips as a function of the minimum temperature, where each point represents a day
# you'll need to summarize the trips and join to the weather data to do this
trips_with_weather |> group_by(date) |> summarize(weather = mean(tmin), count = n()) |> ggplot(aes(x=weather, y=count)) + geom_point()
# repeat this, splitting results by whether there was substantial precipitation or not
# you'll need to decide what constitutes "substantial precipitation" and create a new T/F column to indicate this
trips_with_weather |> mutate(subprec = if_else(prcp > mean(prcp), TRUE, FALSE)) |> group_by(date, subprec) |> summarize(weather = mean(tmin), count = n()) |> ggplot(aes(x=weather, y=count, color = subprec)) + geom_point()
# add a smoothed fit on top of the previous plot, using geom_smooth
trips_with_weather |> 
    mutate(subprec = if_else(prcp > mean(prcp), TRUE, FALSE)) |> 
    group_by(date, subprec) |>
     summarize(weather = mean(tmin), count = n()) |> 
     ggplot(aes(x=weather, y=count, color = subprec)) + geom_point() +
      geom_smooth(method = "lm", se = FALSE)
# compute the average number of trips and standard deviation in number of trips by hour of the day
# hint: use the hour() function from the lubridate package
trips |> mutate(date = as_date(starttime), hour = hour(starttime)) |>
    count(date, hour) |> group_by(hour) |> 
    summarize(average =mean(n), std = sd(n)) |> ggplot(aes(x=hour, y=average)) + 
    geom_line() + 
    geom_ribbon(aes(ymin = average -std, ymax = average + std), alpha=0.25)
# plot the above

# repeat this, but now split the results by day of the week (Monday, Tuesday, ...) or weekday vs. weekend days
# hint: use the wday() function from the lubridate package
trips |> mutate(date = as_date(starttime), hour = hour(starttime), wday = wday(date)) |>
    count(date, hour) #|> group_by(hour, wday) |> 
    summarize(average =mean(n), std = sd(n))  #|> ggplot(aes(x=hour, y=average)) + 
    geom_line() + 
    geom_ribbon(aes(ymin = average -std, ymax = average + std), alpha=0.25) +
    facet_wrap(~wday)

trips |> mutate(date = as_date(starttime), hour = hour(starttime), wday = wday(date)) |>
    group_by(hour) |> summarize(average = mean(sum()), std = sd(count))  #|> ggplot(aes(x=hour, y=average)) + 
    geom_line() + 
    geom_ribbon(aes(ymin = average -std, ymax = average + std), alpha=0.25) +
    facet_wrap(~wday)
