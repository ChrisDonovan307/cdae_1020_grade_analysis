# .Rprofile

# Load utils, so we can use install.packages()
library(utils)

# Set the cloud mirror, which is 'network-close' to everybody, as default
local({
    r <- getOption("repos")
    r["CRAN"] <- "https://cloud.r-project.org"
    options(repos = r)
})

# Install pacman if necessary
suppressWarnings(
    suppressPackageStartupMessages(
        if (!requireNamespace("pacman")) {
            install.packages("pacman", dependencies = TRUE)
        }
    )
)

# Check, install if necessary, and load packages
pacman::p_load(conflicted)

# Load functions, including analyze_grades
files <- list.files('3_functions', full.names = TRUE)
invisible(lapply(files, source))
rm(files)

# Open table of contents
if (Sys.info()["sysname"] == "Mac") {
    tryCatch({
        system('open "table_of_contents.R"')
        cat('\n* Loading Table of Contents *')
    }, error = function(e) {
        cat(
            '\n* NOTE: Rprofile tried to open table_of_contents.R, but I don\'t know how',
            'macs work so it failed. If you\'re seeing this and you want the table',
            'of contents to conveniently appear when you open the project, tell',
            'Chris what the command is. *\n'
        )
    })
    
} else if (Sys.info()["sysname"] == "Windows") {
    tryCatch({
        shell.exec('table_of_contents.R')
        cat('\n* Loading Table of Contents *')
    }, error = function(e) {
        cat('\nNOTE: Could not open table of contents.\n')
    })
    
} else {
    cat('\nNOTE: Could not open table of contents.\n')
}
