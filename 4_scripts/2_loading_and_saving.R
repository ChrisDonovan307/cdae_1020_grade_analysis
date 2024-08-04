# 2. Loading and Saving Data

# Using example data to show how to load, wrangle, and save data



# On the Tidyverse --------------------------------------------------------


#' Before we dive in here, I wanted to provide some context about the Tidyverse
#' and packages use generally. The functions that come with R, known as base R
#' can do a whole lot. They are efficient, both in terms of speed and the amount
#' of lines necessary to write it. But base R is not known for being
#' particularly user-friendly. Many of the functions are ancient, the syntax is
#' inconsistent, and they don't necessarily play well with other packages.

#' Enter the Tidyverse. This is a collection of packages built around the idea 
#' of 'tidy' data, which is a standardized way of structuring data. There are 
#' three principles:
#'  1. Each variable is a column, and each column is a variable.
#'  2. Each observation is a row, and each row is an observation.
#'  3. Each value is a cell, and each cell is a single value.

#' This doesn't sound earth-shattering, but start observing the data you find
#' out in the wild and you will notice that much of it is not structured this
#' way. 

#' But more than that, the Tidyverse is an ecosystem of packages and functions
#' that are intuitive, have consistent syntax, and work well together. Packages
#' include:
#' - tibble: a tidy version of data frames
#' - dplyr: wrangling, cleaning
#' - ggplot2: the most popular graphing package
#' - forcats: for working with factors
#' - purrr: analagous to the apply apply family, working with lists
#' - readr: functions for loading data 
#' - stringr: for working with character strings
#' ... and probably other packages that I've forgotten about.

# We can see some of the differences between tibbles and data frames here:
pacman::p_load(tibble)
mtcars_tibble <- as_tibble(mtcars)

# Check class
class(mtcars)
class(mtcars_tibble)
# Note that the tibble is BOTH a tibble AND a data frame. It works either way.

# Print both
mtcars
mtcars_tibble
#' Notice that the tibble doesn't print the entire df by default, which can be 
#' nice if it is gigantic.

# Check out structures:
str(mtcars)
str(mtcars_tibble)
#' Note that the tibble gives you a bit more information about the df. There are
#' certainly more meaningful differences between base and Tidyverse functions, 
#' but this is just a taste.

#' I have become a follower of the tidy gospel. I think it is easier to learn,
#' easier to write, and easier to read. Tidyverse functions are largely just
#' wrappers for base functions. For example, the `read_csv()` function from
#' readr is nearly the same as the base function `read.csv()`, just with extra
#' features. Similarly, the stringr package is just a bunch of wrappers around
#' the base functions `grep()` and `sub()`.

#' This is all a long-winded way to get to my point here which is that the 
#' Tidyverse is pretty great, but there are drawbacks:

#' - Entering the Tidyverse means loading a bunch of packages when you could
#'    accomplish those same things without loading packages in base R. More 
#'    packages means more dependencies, more packages updates, and potentially
#'    more conflicts with packages outside of the Tidyverse. If you ever want to
#'    write your own package, it is best practice to depend on as few other 
#'    packages as possible. 
#' - Some Tidyverse functions run slower than base functions. For example, 
#'    `map()` runs about 30 milliseconds slower per element than `lapply()`. 
#'    Does this matter? It depends. With small datasets, not at all. With big 
#'    data, it definitely could. But really if we're working with big data, we 
#'    are probably going to abandon base R for the `data.table` packages or 
#'    others that are designed for dealing with big data. 
#' - Learning the Tidyverse might come at the expense of learning how base R
#'    works.

#' So, just keep in mind that while the Tidyverse is pretty nice and I use it
#' most of the time, you should understand both the advantages and drawbacks, 
#' and learn your way around both systems. 



# Load Packages -----------------------------------------------------------


#' Let's revisit loading packages. I mentioned earlier that the whole rigamarole
#' with `install.packages()` can lead to some errors if you already have that
#' package installed. It is also annoying to use that and `library()` for each 
#' package you want to install and load. 

#' This is why I prefer using pacman - short for 'package manager'. pacman 
#' automatically checks whether you have a package installed, installs it if 
#' need be, then loads it. And it can take a series of packages. So, just feed
#' it the packages you want and it will do the rest.

#' A catch here is that you have to have pacman installed first to be able to
#' use it... But I have very sneakily hidden in the housekeeping script a 
#' line that automatically checks for and installs pacman when you run it. Check
#' it out if you're curious.

#' Here, we use the p_load function to load all the packages we want to use.
pacman::p_load(readxl,   # For reading .xlsx or .xls files
               dplyr,    # Pipes, data wrangling
               skimr,    # Skim function
               readr,    # Convenient functions for importing files
               stringr)  # For working with character strings



# Working Directories -----------------------------------------------------


#' To load data from a csv or excel file, we have to tell R where that file
#' lives. The starting point, or where R thinks we are currently, is called the
#' `working directory`. To check your working directory, use:
getwd()
#' This prints the path to your current working directory in your console. We
#' can also change the working directory using `setwd()`, but we really don't 
#' want to here. You will notice that it is already pointing toward the main
#' folder of the project, which we call the `root directory`.

#' If we want to use a path from with our current directory, we don't have to
#' type out that entire thing. For example, try running these lines, which just
#' open the scripts:
file.edit('table_of_contents.R')
file.edit('4_scripts/1_r_basics.R')

#' We call these `relative file paths`, and they are 100x better than the 
#' alternative: `absolute file paths`. Not only is it much easier to write file
#' paths without going all the way to your computer's root directory, but 
#' absolute file paths are always different between computers! With relative 
#' paths, we can share code like this and it will work for everyone, because it
#' is all relative to the project folder, no matter where you put it.



# Loading Data ------------------------------------------------------------


#' Now that we understand working directories, we are going to load some
#' simulated data to work with from excel.
example_data <- read_excel("1_raw/example_grades.xlsx")
head(example_data)
#' Note that the `read_excel` function automatically detects whether a file is
#' a .xls or .xlsx before importing it. 

#' If our data is a .csv, we can instead use the `read_csv` function.
mtcars_example <- read_csv('1_raw/mtcars_csv_example.csv')
head(mtcars_example)

#' There are plenty more functions for loading different kinds of data, like
#' .txt, .tsv, stata files, SAS files, etc. It is also worth exploring options
#' for specifying whether there is a header, what classes each variable are, and
#' so on. Remember, we can look at the details of a function using [?].
?read_csv



# Saving Data -------------------------------------------------------------


#' Let's say we've done some work on a dataframe and we are ready to quit for
#' the day. If we quit R, we will lose all the objects in our environment! This
#' sounds crazy but is by design so we don't get cluttered and we are clear 
#' which data we are working with. To keep an object for later, we use the RDS
#' file format:
saveRDS(example_data,
        '2_clean/example_saved_data.RDS')
#' Note that the first object is the DF and the second is a relative file path
#' that both names the file and specifies the format.

#' Now we are safe to quit R. To load it again later:
same_data <- readRDS('2_clean/example_saved_data.RDS')
head(same_data)



# Clear -------------------------------------------------------------------


#' Let's clean up our environment a bit before we move on with a function I
#' borrowed from the internet that removes datasets and variables, but not
#' functions:
source('3_functions/clear_data.R')
clear_data()

#' Remember that it is a good practice to hit [CTRL/CMD + SHIFT + F10] 
#' frequently to restart with a clean session. Just make sure you've saved
#' all the objects you care about!