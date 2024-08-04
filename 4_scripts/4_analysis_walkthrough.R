#' 4. Analysis Walkthrough

#' This is a walkthrough script to get you started cleaning, visualizing, and
#' analyzing cohort grades. We will be using some simulated example data. Note
#' that I'm backing off with the instruction here and mostly showing examples
#' for you to explore and learn from. Everything here should already work, so
#' you can just read along and keep hitting [CTRL/CMD + ENTER] to run the next
#' line of code.



# Load Packages and Data --------------------------------------------------


# Load packages
pacman::p_load(dplyr,      # tidyverse package for wrangling data
               ggplot2,    # tidyverse package for graphs
               readr,      # tidyverse package for loading data
               stringr,    # convenient package for working with strings
               readxl,     # reads excel files
               janitor,    # convenient package for cleaning data
               skimr,      # nice package for seeing characteristics of data
               multcomp,   # for posthoc test
               multcompView,
               emmeans,    # for posthoc test
               conflicted) # for dealing with function name conflicts

# Load data, assign it to object
clean <- readRDS('2_clean/clean_data.rds')

# Take another moment to explore the data:
class(clean)
str(clean)
head(clean)
skim(clean)



# Summary Stats -----------------------------------------------------------
    

# Look at means
clean |> 
    group_by(ta_name) |> 
    summarize(mean_week_2 = mean(week2, na.rm = TRUE),
              mean_week_3 = mean(week3, na.rm = TRUE),
              mean_week_4 = mean(week4, na.rm = TRUE))

# What about without zeroes?
# Look at one week at a time, here just week 2
clean |> 
    select(-week3, -week4) |> # Here we remove columns rather than select
    filter(week2 != 0) |> 
    group_by(ta_name) |> 
    summarize(mean_week_2 = mean(week2),
              median_week_2 = median(week2))

# Filter out zeroes from week2 and save the object over itself.
clean <- clean |> 
    select(ta_name, week2) |> 
    filter(week2 != 0)
# These are not representative of how TAs are grading
# So we usually want to remove them



# Graph -------------------------------------------------------------------


# Basic histogram
hist(clean$week2)

# Table
table(clean$week2)
table(clean$week2, useNA = 'always')
# Note the difference between these tables. NAs are not shown by default

# Boxplot with ggplot2
clean |> 
    ggplot(aes(x = reorder(ta_name, week2), # map aesthetics, name x and y vars
               y = week2)) +                  # also reorder by value
    geom_boxplot() +                        # call for boxplot
    theme_classic() +                       # preset theme to make it pretty
    theme(axis.text.x =                     # edit x axis labels
              element_text(                 
                  angle = 90,               # turn them 90 degrees
                  vjust = 0.5,              # vertical adjustment
                  hjust = 1)) +             # horizontal adjustment
    ggtitle("Week 2 Analysis") +            # graph title
    xlab("Cohort") +                        # x axis label
    ylab("Week 2 Grades") +                 # y axis label
    scale_y_continuous(breaks = 1:10)       # set scale of y axis from 1 to 10

# Get means a and standard deviations to graph
# This is also possible within ggplot, but I find this easier
clean_summary <- clean |> 
    group_by(ta_name) |> 
    summarize(mean_week_2 = mean(week2),    # get means
              sd = sd(week2))               # get standard deviations

# point graph with summary data
clean_summary |> 
    ggplot(aes(x = reorder(ta_name, mean_week_2), y = mean_week_2)) +
    geom_point() +
    geom_errorbar(aes(x = ta_name,               # error bars
                      ymin = mean_week_2 - sd,   # bottom of error bar
                      ymax = mean_week_2 + sd),  # top of error bar
                  width = 0.4) +                 # width of error bar
    theme_classic() +
    theme(axis.text.x =                          
              element_text(
                  angle = 90,
                  vjust = 0.5,
                  hjust = 1)) +
    labs(x = "Cohort",                           # various labels and titles
         y = "Mean Week 2",
         title = "Week 2 Analysis Means with SD",
         subtitle = "A very nice graph!") +
    scale_y_continuous(breaks = 1:10)



# Analysis ----------------------------------------------------------------


#' Note here that we don't likely have big enough sample sizes for most big n 
#' methods if there are ~20 students per cohort, so interpret with caution.

#' First let's explore the distribution of our data
hist(clean$week2)

# Let's try a qqplot to explore normality
qqnorm(clean$week2)
qqline(clean$week2, col = 'red')

#' The shapiro test is for marginal normality of distribution. Note that these
#' tests tend to be overpowered and are maybe not the best thing to be showing
#' here, but it's worth knowing how to do them at least. Also, this is a weird
#' place to rant about it, but normality of predictor variables is not actually
#' an assumption of regression or most any other similar test. Instead, we need
#' to show normality of residuals. Anyhow, here's the shapiro test:
shapiro.test(clean$week2)
# if p < 0.05, we reject the null that the distribution is normal

# We can also check for equality of variance between groups
levene.test(clean$week2, clean$ta_name)
# If p < 0.05, we reject the null of equal variance between groups

#' Let's run an ANOVA to explore whether there are differences in means across
#' groups. This is not actually appropriate here, but whatever. 
model <- aov(week2 ~ ta_name, data = clean)
summary(model)

#' Now let's check out the residuals:
par(mfrow = c(2, 2))
plot(model)
par(mfrow = c(1, 1))
#' This is a ridiculously jenky simulated dataset and an inappropriate test,
#' so none of these look good!

#' Moving right along though, we cna run a posthoc test to see which groups
#' are different from one another, with an adjustment for multiple comparisons
cld(emmeans(model, "ta_name", type = "response"), Letters = "abcdefg")

#' A slightly better option is a Kruskal-Wallis test, which is a non-parametric
#' version of the ANOVA that looks for differences in medians.
kruskal.test(clean$week2, clean$ta_name)
#' If p < 0.05, we reject the null that there are no differences in medians.

#' A posthoc test here will be the Dunn test:
dunn.test(
    clean$week2,
    clean$ta_name,
    method = 'bonferroni',
    kw = FALSE,
    table = FALSE
) %>% 
    as.data.frame() %>% 
    filter(P.adjusted <= 0.05) %>% 
    mutate(across(where(is.numeric), ~ format(round(., 3), nsmall = 3)))
#' This takes a bit of wrangling, but makes an adjustment for multiple 
#' comparisons and shows which groups are different.


#' Here ends out tour for now!
clear_data()
