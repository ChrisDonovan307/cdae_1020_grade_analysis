# Clear Data

# Put this at end of scripts to remove non-function objects
clear_data <- \() {
  rm(list = setdiff(ls(envir = .GlobalEnv),
                    lsf.str(envir = .GlobalEnv)),
     envir = .GlobalEnv)
}