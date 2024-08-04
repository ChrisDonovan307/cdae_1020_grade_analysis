# 6. Use the analyze grades function

# Now that you know how to use the analyze_grades function, start over with real
# data here. Steps are outlined below.



# 1. Load Function --------------------------------------------------------

source('3_functions/analyze_grades.R')


# 2. Load Data ------------------------------------------------------------

# Remember that in a project, file paths start from the main project folder.
dat <- read_excel('put/file/path/here.xlsx')
dat <- read_csv('put/file/path/here.csv')


# Clean up Names ----------------------------------------------------------

# optional, but helpful if names are long and gross


# Use Function ------------------------------------------------------------

# Remember to put commas after every argument
results <- analyze_grades(
    df = 
    cohort_column =
    username_column =
    assignment_column =
    clean_assignment_name =
    remove_zeroes =
    print_only =
    split_cohort_names =
    split_character =
    name_before_or_after =
)


# Save Results ------------------------------------------------------------

saveRDS(results, 'put/file/path/here.rds')