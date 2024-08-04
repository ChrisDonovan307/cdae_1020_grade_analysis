# 5. How to use the analyze_grades function

#' This is a walkthrough showing you how to use the analyze_grades function. We
#' are going to use simulated data to play around with.

#' Quick note before we begin - there is a growing list of things I'd like to
#' change about this function including a few bugs. I decided not to pursue any
#' more of them and convert it into the Shiny App instead. That will really be
#' the best way to do this if you want it to be as easy as possible. I'm leaving
#' this here for posterity though.



# Housekeeping ------------------------------------------------------------


# Check for pacman, install if necessary
if (!require(pacman)) {
    install.packages('pacman', dependencies = TRUE)
}

# Check, install, load all other packages
pacman::p_load(ggplot2,
               readr,
               readxl,
               rlang,
               multcomp,
               emmeans,
               conflicted,
               knitr,
               stringr)

# Load up analyze_grades function
source('3_functions/analyze_grades.R')



# Wrangle Data ------------------------------------------------------------


# First, we are going to load some anonymized example data
raw <- read_excel("1_raw/example_grades.xlsx")
# Note that our file happens to be a .xlsx here, so we use the read_excel()
# function to save it as an object. If our data is a .csv, we will instead use
# read_csv(). Also note that the file path given is relative to the project
# folder. To get to our file from the main project folder, we first go to 
# the example_data folder, and then find our file by name. 

names(raw)
# Note that these names are weird and gross because of how they came out of 
# Brightspace. Cleaning these up and getting rid of extraneous columns will
# make our life easier.

# First we will select the columns we are interested in. There are a bunch of 
# ways to do this, and they all end up the same:

# 1.
dat <- raw[, 1:6]
str(dat)
names(dat)
# This is called indexing. The first number (before the comma, none shown here)
# are the rows to select. We want all the rows, so we leave that blank. The
# second number (1 through 7) are the column numbers we want to select. This is 
# a pretty convenient way to select, but note that you need to know the indices
# of your columns ahead of time to use it. If you would rather select by column
# name instead, we can use the dplyr::select() function:

# 2.
dat2 <- raw |> 
    select(
        Student_NAME,
        'TA_grading Cohort - these are the names of TAs in each cohort',
        Assignment.1
    )
str(dat2)
names(dat2)
# This is how we use dplyr to select by column name. It is sometimes convenient,
# but not when the name is ridiculously long! Note that we usually don't have 
# to include quotes for queries in select(), UNLESS there are spaces in the 
# name. It is best practice to avoid spaces in names, but this is how 
# Brightspace gave us this data, so we have to deal. On the plus side, it 
# doesn't matter what order our original columns are in. This will always pull
# out the ones we want (and put them in the order we specify here). 

# 3.
dat3 <- raw |> 
    select(Student_NAME:junk)
str(dat3)
names(dat3)
# Here we use select again, but we select the entire range of columns between
# Student_NAME and 'junk'. 

# 4.
dat4 <- raw |> 
    select(1:5)
str(dat4)
names(dat4)
# We can also use select just like indexing in example 1! There is no comma
# in the query here because the select() function only choose columns, not rows.

# There are also lots of ways to rename columns. Dplyr::rename is a good one
# that provides a lot of options, like with select(). The new name comes first,
# followed by the column you want to rename.
dat_named <- dat |> 
    rename(                          # We can rename by...
        user = 1,                       # column index,
        ta_name = 2,
        project = PROJECT,              # column name,
        week2 = contains('ent.1'),      # or various other ways...    
        week3 = starts_with('third_'),
        week4 = last_col()
    )
names(dat_named)
# Much better!

# Here is another way using the names() function you've already been seeing.
names(dat3) <- c('user', 'ta_name', 'project', 'week2', 'week3', 'week4', 'junk')
names(dat3)

# Let's save dat_named to a new object to run the function with
my_data <- dat_named



# Learn about it! ---------------------------------------------------------


# Here is an example of what using the function will look like. There are only
# 3 required arguments.

analyze_grades(
    df = my_data,                  # your data frame
    cohort_column = 'ta_name',     # name of cohort columns (quotes required)
    assignment_column = 'week2'    # name of assignment column (quotes required)
)
# Using only the required arguments is fine but there are many more features 
# you should use!

# Let's see what other arguments are called for in this function:
args(analyze_grades)
# You'll notice that many arguments are already set with defaults, like 
# print_only = TRUE. This means that if you don't specify that argument, it will
# assume you want it to be TRUE. However, you can tell which arguments are 
# required because they have no default. You MUST enter arguments for df, 
# cohort_column, and assignment_column. 

# Here is how it will look to use the function with all the features. In the 
# margins I will specify what kind of argument it is expecting. Functions are
# very picky. If you don't give it what it wants, it will throw an error.

analyze_grades(
    df = my_data,                                # object of class data.frame
    cohort_column = 'ta_name',                   # character string (quotes)
    username_column = 'user',                    # character string (quotes)
    assignment_column = 'week2',                 # character string (quotes)
    clean_assignment_name = "Week 2 Analysis",   # character string (quotes)
    remove_zeroes = TRUE,                        # logical (TRUE or FALSE)
    print_only = TRUE,                           # logical (TRUE or FALSE)
    split_cohort_names = TRUE,                   # logical (TRUE or FALSE)
    split_character = '-',                       # character string (quotes)
    name_before_or_after = 'after'               # 'before' or 'after' (quotes)
)

# Let's walk through these optional arguments.

# username_column: If this is included, the function will check for student
# view accounts (username containing '_sv') and remove them

# clean_assignment_name: This is a nicer looking name of the assignment column
# that will be used to make labels for graphs.

# remove_zeroes: Pretty straightforward. We generally want to remove these.

# print_only: If we only want to view results in RStudio, put TRUE here. This 
# will  print results to the console and plot windows and formatting will
# come through nicely. If we want to save the results to an object, put FALSE 
# here. Results will still be printed, but formatting won't be as nice. However,
# we do this if we want to save the results to put in a markdown or some such.

# split_cohort_names: You may have noticed that cohort names are long and 
# unwieldy ('Cohort 1 - TA Name'). This is fine, but it takes up space in 
# graphs, and we can do better. If you you want to split these names based on a
# character (like a dash), put TRUE here.

# split_character: If split_cohort_names = TRUE, you MUST include a string on 
# which to split these names. A dash '-' is a likely entry here. 

# name_before_or_after: If split_cohort_names = TRUE, you MUST include direction
# on whether to keep the text before the split ('-') or after it. The only two
# acceptable inputs here are 'before' and 'after'.



# Run it! -----------------------------------------------------------------


# Okay, let's give it a try!
analyze_grades(
    df = my_data,
    cohort_column = 'ta_name',
    username_column = 'user',
    assignment_column = 'week2',
    clean_assignment_name = "Week 2 Analysis",
    remove_zeroes = TRUE,
    print_only = TRUE,
    split_cohort_names = TRUE,
    split_character = '-',
    name_before_or_after = 'after'
)

# In the plots viewer, you should have a graph of means and SDs as well as a 
# boxplot with medians (hit the arrows in the viewer to switch to that one). 
# Try hitting 'Ctrl + Shift + 6' to go full-screen on the viewer. Hit it again
# to go back to normal.

# In the console will be a heap of stuff. Hit 'Ctrl + Shift + 2' for 
# full-screen here also. You will see:

# 1. A log reporting how things went. This is mostly for troubleshooting if it
# it breaks, but also has some useful information about what happened.

# 2. A note explaining the consequences of the print_only argument and how to 
# save results with print_only = FALSE.

# 3. A Summary Table with some general information about the data you entered.
# Take a look for weird things like high numbers of NAs removed. Investigate
# why that happened if this is the case. 

# 4. A table of Means by Cohort, along with the number of students in each one.
# Note that these means adhere to your choice in the  remove_zeroes argument. 

# 5. An ANOVA of grades by cohort. Note that the sample sizes here are 
# technically too small for an ANOVA, so interpret results with caution. 

# 5.5 (Maybe) If the ANOVA is significant, the function will automatically run
# a pairwise posthoc test with Tukey adjustment for multiple comparisons to 
# identify which cohorts are significantly different from one another. 

# 6. Interpretation of ANOVA. 

# 7. An inspirational message. You did great!

# 8. (Maybe) There could be warnings associated the analysis. This does not
# mean anything went wrong necessarily, but make sure you're okay with 
# whatever it's telling you. 



# Save it! ----------------------------------------------------------------


# If you want to save the results for later, use print_only = FALSE, and 
# the assignment operator to save it as an object. Here's the same thing again, 
# but saved to an object:
results <- analyze_grades(
    df = my_data,
    cohort_column = 'ta_name',
    username_column = 'user',
    assignment_column = 'week2',
    clean_assignment_name = "Week 2 Analysis",
    remove_zeroes = TRUE,
    print_only = FALSE,
    split_cohort_names = TRUE,
    split_character = '-',
    name_before_or_after = 'after'
)

# You'll notice that no plots appeared. In the console, you still get the log, 
# a note about how to save to a list, an inspirational message, and possibly 
# some warnings.

# Results are now saved in a list object called 'results'. This is a little 
# different to deal with than data frames and vectors. A list is a series of 
# elements much like a vector, except that each element can be ANY kind of 
# object, including a data frame, a model, a graph, or another list. This makes
# lists incredibly useful! (Seriously. Learn how to use lists. It makes 
# everything better.)

# Let's see what it's all about:
class(results)
length(results)
names(results)
str(results, max.level = 1, strict.width = 'cut')

# Our 'results' object is a list of 6 elements, one for each of our outputs! 
# Note that some of these objects are rather complex. Watch what happens when 
# we try to use str() without limiting the output:
str(results)
# Quite a mess, eh?

# To access an element of the list, we index using double brackets [[ ]], either
# by name or index number. 

# For example, to pull out the boxplot:
results[['Boxplot']]
results[[1]]
# These are the same, because 'Boxplot' is the first element of the list

# To save these results, we can use the saveRDS() function with a file path.
saveRDS(results, '5_results/my_list_of_results.rds')
# Note that the first argument is the object name, but the file will be saved
# with the name given in the file path (my_list_of_results). Remember to give it
# the .rds extension. Check the folder and see if it's there!

# To pull this out again in another script, we can use the readRDS() function.
old_results <- readRDS('5_results/my_list_of_results.rds')



# Parting Thoughts --------------------------------------------------------


# Now that you have a handle on how this function works, you should know that
# you don't actually have to open this script to use it. You WILL have to load
# the function, though. You can do this by sourcing the clean version of the 
# function:
source('3_functions/analyze_grades.R')

# Now you should have the analyze_grades function loaded into your global 
# environment, and you can use it in any new script! Remember that just like a 
# package, you will have to load this every time you start a session in R.

clear_data()