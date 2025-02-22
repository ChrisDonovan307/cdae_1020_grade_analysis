# Housekeeping ------------------------------------------------------------


# Check for pacman, install if necessary
if (!require(pacman)) {
    install.packages('pacman', dependencies = TRUE)
}

# Check, install, load all other packages
pacman::p_load(dplyr,
               tibble,
               ggplot2,
               readr,
               readxl,
               rlang,
               multcomp,
               emmeans,
               conflicted,
               knitr,
               dunn.test,
               lawstat,
               stringr)

# Set winners for conflicts
conflicts_prefer(
    dplyr::filter(),
    dplyr::select(),
    dplyr::summarize(),
    dplyr::first(),
    dplyr::last(),
    .quiet = TRUE
)



# analyze_grades Function -------------------------------------------------

analyze_grades <- function(df,
                           cohort_column,
                           username_column = NULL,
                           assignment_column,
                           clean_assignment_name = NULL,
                           remove_zeroes = TRUE,
                           print_only = TRUE,
                           split_cohort_names = FALSE,
                           split_character = NULL,
                           name_before_or_after = NULL,
                           motivational_messages = TRUE) {
    
    # Assert data formats -----
    if (!is.data.frame(df)) {
        stop(cat('\n**FIX: df argument must be a data frame or tibble. Use', 
                 'class(df) to check the class of an object.**\n\n'))
    }
    
    if (!is.character(cohort_column)) {
        stop(cat('\n**FIX: cohort_column argument must be a character class',
                 '(with quotes)**\n\n'))
    }
    
    if (!is.character(assignment_column)) {
        stop(cat('\n**FIX: assignment_column argument must be a character',
                 'class (with quotes)**\n\n'))
    }
    
    if (!is.null(clean_assignment_name)) {
        if (!is.character(clean_assignment_name)) {
            stop(cat('\n**FIX: clean_assignment_name argument must be a',
                     'character class (with quotes)**\n\n'))
        }
    }
    
    if (!is.logical(remove_zeroes)) {
        stop(cat('\n**FIX: remove_zeroes argument must be logical',
                 '(TRUE or FALSE)**\n\n'))
    }
    
    if (!is.logical(motivational_messages)) {
        stop(cat('\n**FIX: motivational_messages argument must be logical',
                 '(TRUE or FALSE)**\n\n'))
    }
    
    if (!is.logical(split_cohort_names)) {
        stop(cat('\n**FIX: split argument must be logical',
                 '(TRUE or FALSE)**\n\n'))
    }
    
    if (!is.logical(print_only)) {
        stop(cat('\n**FIX: print_only argument must be logical',
                 '(TRUE or FALSE)**\n\n'))
    }
    
    if (split_cohort_names == TRUE) {
        if (!is.character(split_character) || is.null(split_character)) {
            stop(
                cat(
                    '\n**FIX: if split_cohort_names = TRUE, the split_character',
                    'argument is required and must be character class',
                    '(with quotes)**\n\n'
                )
            )
        }
        
        if (is.null(name_before_or_after) ||
            !(name_before_or_after %in% c('before', 'after'))) {
            stop(
                cat(
                    '\n**FIX: if split_cohort_names = TRUE, the',
                    'name_before_or_after argument must',
                    'either be "before" or "after" (with quotes)**\n\n'
                )
            )
        }
    }
    
    cat('\n*asserting successful*\n')
    
    # Filtering -----
    
    # If no clean name given, use assignment
    if (is.null(clean_assignment_name)) {
        clean_assignment_name <- assignment_column
    }
    
    # filter out _sv if username_column is provided
    if (!is.null(username_column)) {
        df <- df |>
            filter(str_detect({{ username_column }}, '_sv') == FALSE)
        
        cat('*removing student view accounts*\n')
    } else {
        warning(
            paste(
                '** Did NOT check or remove student view accounts.',
                'To do so, you must include an input for the',
                'username_column argument **\n'),
            call. = FALSE)   
    }    
    
    # Select rows, rename columns, remove NA cohorts
    df <- df |> 
        select(cohort = {{ cohort_column }}, 
               assignment = {{ assignment_column }}) 
    
    dat <- df |> 
        filter(!is.na(cohort))
    
    # Count how many NAs were lost
    na_cohort_count <- nrow(df) - nrow(dat)
    
    # If any lost, send a warning
    if (na_cohort_count > 0) {
        warning(
            paste(
                '**',
                na_cohort_count,
                'row(s) removed because cohort was NA **'
            ),
            call. = FALSE
        )
    }
    
    # Get number of zeroes
    number_of_zeroes <- sum(dat$assignment == 0, na.rm = TRUE)
    
    # Remove zeroes if chosen
    if (remove_zeroes == TRUE) {
        
        dat <- filter(dat, assignment != 0)
        # Make a label to put in graph subtitle based on choice
        zeroes_subtitle <- 'All zeroes removed'
        
    } else {
        zeroes_subtitle <- 'Includes zeroes'
        
        warning('** Did NOT remove zeroes before analysis. To do so, set the ',
                'remove_zeroes argument to TRUE. **',
                call. = FALSE)
    }
    
    cat('*filtering successful*\n')
    
    # Split Cohort Names -----
    if (split_cohort_names == TRUE) {
        
        keep <- case_when(name_before_or_after == 'before' ~ 1,
                          name_before_or_after == 'after' ~ 2)
        dat$cohort <- str_split_i(dat$cohort, split_character, keep) |>
            str_trim(side = 'both')
        left_or_right <- case_when(keep == 1 ~ 'left',
                                   keep == 2 ~ 'right')
        cat('*keeping',
            left_or_right,
            'side of cohort names*\n')
    }
    
    # Results list
    results <- list()
    
    # Histogram -----
    results[['Histogram']] <- dat |> 
        ggplot(aes(x = assignment)) +
        geom_histogram(binwidth = 1,
                       fill = 'grey',
                       color = 'black') +
        theme_classic() +
        labs(x = paste(clean_assignment_name, 'Grades'),
             y = 'Count',
             title = paste('Histogram of', clean_assignment_name, 'Grades'))
    
    # Boxplot -----
    results[['Boxplot']] <- dat |> 
        ggplot(aes(x = reorder(cohort, assignment, FUN = median), 
                   y = assignment)) +
        geom_boxplot(outliers = FALSE) +
        geom_jitter(width = 0.1,
                    alpha = 0.4) +
        theme_classic() + 
        theme(axis.text.x = element_text(angle = 90, 
                                         vjust = 0.5, 
                                         hjust = 1),
              axis.text = element_text(size = 12),
              axis.title = element_text(size = 14),
              plot.title = element_text(size = 16),
              plot.subtitle = element_text(size = 14)) +
        labs(title = paste('Median', clean_assignment_name, "Grades"),
             subtitle = zeroes_subtitle) +
        xlab("Cohort") +
        ylab(paste(clean_assignment_name, "Grades")) +
        scale_y_continuous(breaks = 1:10)
    
    cat('*boxplot successful*\n')
    
    # data for summary
    dat_sum <- dat |> 
        group_by(cohort) |> 
        summarize(mean = mean(assignment),
                  sd = sd(assignment))
    
    # Means graph -----
    results[['Means_Graph']] <- dat_sum |> 
        ggplot(aes(x = reorder(cohort, mean), y = mean)) +
        geom_point() +
        geom_errorbar(aes(x = cohort, 
                          ymin = mean - sd, 
                          ymax = mean + sd), 
                      width = 0.4) +
        theme_classic() + 
        theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) +
        labs(x = "Cohort",
             y = paste('Mean', clean_assignment_name, 'Grade'),
             title = paste('Mean ',clean_assignment_name, 'Grades with SDs'),
             subtitle = zeroes_subtitle) +
        scale_y_continuous(breaks = 1:10)
    
    cat('*means graph successful*\n')
    
    # Summary Stats Table -----
    results[['Summary_Table']] <- dat |>
        summarize(
            'Mean Grade (After Zeroes Selection)' = round(mean(assignment, na.rm = TRUE), 2),
            'Median Grade (After Zeroes Selection)' = round(median(assignment, na.rm = TRUE), 2),
            'Zeroes in OG Data' = as.character(number_of_zeroes),
            'NA Cohorts in OG Data' = as.character(na_cohort_count),
            'Total Students in OG Data' = as.character(nrow(df)),
            'Total Students in Filtered Data' = as.character(nrow(dat))
        ) |>
        t() |>
        knitr::kable()
    
    cat('*summary stats successful*\n')
    
    # Means by Cohort Table -----
    results[['Means_by_cohort']] <- dat |> 
        group_by(cohort) |> 
        summarize(mean = format(round(mean(assignment), 2), nsmall = 2),
                  n = n()) |> 
        arrange(mean) |> 
        knitr::kable()
    
    cat('*means by cohort successful*\n')
    
    # Levene Test -----
    results[['Levene_Test']] <- levene.test(dat$assignment, group = dat$cohort)
    
    
    # Kruskal Wallis Test -----
    results[['Kruskal_Wallis']] <- kruskal.test(assignment ~ cohort, data = dat)
    
    cat('*Kruskal Wallis successful*\n')
    
    # Dunn Test -----
    p <- results[['Kruskal_Wallis']]$p.value
    
    if (p < 0.05) {
        
        results[['Dunn_Test']] <-
            dunn.test(
                dat$assignment,
                dat$cohort,
                method = 'bonferroni',
                kw = FALSE,
                table = FALSE
            ) |>
            as.data.frame() |> 
            filter(P.adjusted <= 0.05) |> 
            mutate(across(where(is.numeric), ~format(round(., 3), nsmall = 3)))
        
        cat('*Dunn test successful*\n')
        
    } else {
        
        results[['Dunn_Test']] <- c(
            'Kruskal Wallis test was not significant, so no Dunn test was run.')
        
        cat('*no posthoc test needed - insignificant p value in Kruskal Wallis*')
    }
    
    
    # Interpretation -----
    # List for interpretation and motivation
    
    messages_output <- list()
    
    if (p < 0.05) {
        messages_output[['interpretation']] <-
            paste(
                '\nInterpretation: The p-value of the Kruskal-Wallis test is',
                format(round(p, 3), nsmall = 3),
                'which means there are significant differences between the',
                'cohorts. The Dunn test shows which cohorts are',
                'significantly different from one another.\n'
            )
        
    } else if (p >= 0.05) {
        messages_output[['interpretation']] <-
            paste(
                '\nInterpretation: The p-value of the Kruskal-Wallis test is',
                format(round(p, 3), nsmall = 3),
                'which means there are no significant',
                'differences between the cohorts.\n'
            )
    }
    
    # Motivational messages -----
    if (motivational_messages == TRUE) {
        
        messages <- list(
            'Interpret this: You\'re doing great!',
            'You\'re an R wizard. A wizaRd!',
            'That analysis didn\'t stand a chance against you!',
            'Job skills look good on you!',
            'You\'re an excellent TA, and your work is meaningful!',
            'You are more than your productivity!',
            'Remember to make time for the things you enjoy!',
            'Think of how far you\'ve come!',
            'Whatever these results show, remember that you are statistically significant!'
        )
        which_message <- sample(1:length(messages), 1)
        
        messages_output[['chosen_message']] <-
            paste0('\n',
                   messages[[which_message]],
                   '\n\n')
    }
    
    # Return Results ------
    
    # If print_only is TRUE, only print results. 
    if (print_only == TRUE) {
        
        cat('\nNOTE: When print_only = TRUE, results are shown, but not saved. ',
            'If you want to save the results, use print_only = FALSE and ',
            'assign the output to an object. For example:\n\n',
            '  results <- analyze_grades(...)\n  print(results)\n\n',
            'Otherwise, results will not be saved.\n\n',
            sep = '')
        print(results[1:3]) # graphs
        outputs <- results[4:length(results)] # the stats
        
        for (i in seq_along(outputs)) {
            
            cat('\n\n~~~~~',
                names(outputs)[i],
                '~~~~~\n\n')
            
            print(outputs[i])
        }
        
        cat(messages_output[['interpretation']])
        cat(messages_output[['chosen_message']])
        
        # Otherwise, return results as a list
    } else if (print_only == FALSE) {
        
        cat('\nNOTE: When print_only = FALSE, results are returned as a list. Make ',
            'sure to assign the function to an object. For example:\n\n',
            '  results <- analyze_grades(...)\n  print(results)\n\n',
            'Otherwise, if you just want to see the results, use print_only = TRUE ',
            'to get nicely formatted results in the console.\n\n',
            sep = "")
        cat(messages_output[['chosen_message']])
        return(results)
    }
}

