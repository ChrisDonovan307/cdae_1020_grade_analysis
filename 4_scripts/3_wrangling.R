# 3. Wrangling Data

#' This is a `very` brief introduction to cleaning and wrangling data. There
#' are far more in-depth guides listed on the README, so check that out if you 
#' want to learn more.



# Load Packages and Data --------------------------------------------------


pacman::p_load(
  dplyr,
  readxl,
  stringr,
  skimr,
  janitor
)

# Load our example data from excel again
raw <- read_excel("1_raw/example_grades.xlsx")



# Selecting Columns -------------------------------------------------------


# Check the class of the object
class(raw)

# Check names
names(raw)
# Note that these names are weird and gross. Cleaning these up and getting rid
# of extraneous columns will make our lives easier.

# First we will select the columns we are interested in. There are a bunch of 
# ways to do this, and they all end up the same:

# 1.
dat <- raw[, 1:6]
str(dat)
names(dat)
# This is called indexing. The first number (before the comma, none shown here)
# are the rows to select. We want all the rows, so we leave that blank. The
# second number (1 through 6) are the column numbers we want to select. This is 
# a pretty convenient way to select, but note that you need to know the indices
# of your columns ahead of time to use it. If you would rather select by column
# name instead, we can use the select function from dplyr:

# 2.
dat2 <- raw %>% 
  select(
    Student_NAME,
    'TA_grading Cohort - these are the names of TAs in each cohort',
    Assignment.1
  )
str(dat2)
names(dat2)
# This is how we use dplyr to select by column name. It is sometimes convenient,
# but not when the name is ridiculously long! Note that we usually don't have to
# include quotes for queries in select(), unless there are spaces in the name.
# It is best practice to avoid spaces in names, but sometimes this is what we've
# got and we have to deal. On the plus side, it doesn't matter what order our
# original columns are in. This will always pull out the ones we want (and put
# them in the order we specify here).

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



# Renaming Columns --------------------------------------------------------


# There are also lots of ways to rename columns. Dplyr::rename is a good one
# that provides a lot of options, like with select(). The new name comes first,
# followed by the column you want to rename.
dat <- dat |> 
  rename(                          # We can rename by...
    user = 1,                       # column index,
    ta_name = 2,
    project = PROJECT,              # column name,
    week2 = contains('ent.1'),      # or various other ways...    
    week3 = starts_with('third_'),
    week4 = last_col()
  )
names(dat)
# Much better!

# Here is another way using the names() function you've already been seeing.
names(dat3) <- c('user', 'ta_name', 'project', 'week2', 'week3', 'week4', 'junk')
names(dat3)

#' Here is a helpful functino for cleaning up names. First check out the default
#' names for the iris dataset:
names(iris)

#' We can use `clean_names`, which will convert to snake case by default
iris %>% 
  janitor::clean_names() %>% 
  names()

#' But there are many other options we can use. Here are just a few examples:
iris %>% 
  janitor::clean_names('small_camel') %>% 
  names()

iris %>%
  janitor::clean_names('all_caps') %>%
  names()

iris %>% 
  janitor::clean_names('random') %>% 
  names()



# Cleaning ----------------------------------------------------------------


# First, see if there are any usernames containing _sv
# These are the student view accounts. We want to get rid of them.
any(str_detect(dat$user, '_sv'))
# Yes!

# Next, we can see how many
sum(str_detect(dat$user, '_sv'))
# Just 1

# Now we will filter it out
dat <- dat |> 
  filter(str_detect(dat$user, '_sv') == FALSE)

# Let's check again if we have any left
any(str_detect(dat$user, '_sv'))
# Nope, we're good!

# Convenient function to check for missing data from the skimr package:
skim(dat)
# Note that we have some missing data

# It's best to figure out why you're missing data before you delete it. Listwise
# deletion is not a best practice. But this is just example data, so we're 
# going to use na.omit() to get rid of any line that contains an NA.
dat <- na.omit(dat)
skim(dat)
# Better!

# Now we're done cleaning. Let's save our data as a .RDS file for later.
saveRDS(dat, '2_clean/clean_data.rds')
# Now on to the 4_analysis_walkthrough.R script!

clear_data()