# 7. Settings and Shortcuts


# Settings ----------------------------------------------------------------


#' Make sure these three options in Code > Display > Syntax are turned on:
#'  - rainbow parentheses
#'  - highlight function call
#'  - enable preview of named and hexidecimal colors

#' Make sure these settings under General are turned off:
#'  - Restore most recently opened project at startup
#'  - Restore previously open source documents at startup
#'  - Restore .RData into workspace at startup



# R Admin -----------------------------------------------------------------


# Check R version
R.Version()

# Update R Version
'https://cran.r-project.org/'

# Check Rstudio version
#   Tools > Help > About RStudio (for PC)
#   RStudio > About RStudio (for Mac)

# Update RStudio Version
'https://posit.co/downloads/'

# Update packages
update.packages(ask = FALSE)

# Citing R
citation()

# Citing a package
citation(package = 'dplyr')



# Shortcuts ---------------------------------------------------------------


#' Search settings: [CTRL / CMD + SHIFT + P]
#'  This is a ridiculously helpful command for navigating any kind of settings.
#'  No need to poke around through the menu options, or use your mouse at all,
#'  just hit this and search! Many options can be set from here. 

#' Show shortcuts: [ALT + SHIFT + K]
#'  Brings up a window with common shortcuts. Note that there are many more, 
#'  these are just some commons ones.

#' Modify keyboard shortcuts:
#'  No shortcut for this, but you can find it by searching like described above.
#'  You can remap any hotkeys you like. Many very helpful commands do not have
#'  a hotkey mapped by default.



## Navigating Script -------------------------------------------------------


#' I won't list out all the typical ones like HOME, END, CTRL + END, 
#' CTRL + DELETE / BACKSPACE, but know that they work and are immensely useful.

#' Fold Code: [CTRL + SHIFT + R]
#'  Create a fold and prompts you for a title. This will show up in the 
#'  navigation pane.

#' Open navigation pane: [CTRL + SHIFT + O] 
#'  Opens pane on the right that shows fold titles. 

#' Jump to Section [CTRL + SHIFT + J]
#'  Opens up a tab in the bottom to jump to a named section.

#' Move line up or down [ALT + UP / DOWN]
#'  Hnnggg

#' Copy line up or down [ALT + SHIFT + UP / DOWN]

#' Delete Line [CTRL + D]

#' Delete text to end of line [ALT + BACKSPACE / DELETE]
#'  Does not delete the line itself

#' Select line [CTRL + ALT + L]
#'  Highlights entirety of current line

#' Definition: [F2] / [CTRL + LEFT CLICK]
#'  If used on a function, it opens the source code of the function. If used on 
#'  a file path, it opens that file. If used on a data frame, it opens that DF 
#'  in the viewer. Pretty nice.



## Formatting --------------------------------------------------------------


#' Reformat Code [CTRL + SHIFT + A]
#'  This is so fucking great. Doesn't always do what I want, but real nice. 
#'  Highlight a section of code before hitting this to make it all neat.

#' Comment Lines [CTRL + SHIFT + C]
#'  So good. Turns a line or all selected lines into a comment. Or uncomments.
#'  Great if you want to temporarily erase a section.

#' Multiline Comment: NA
#'  You can turn this on in the settings so that when you hit ENTER in a comment
#'  it will continue the comment on the next line. Even better than that is use
#'  the [#'] marks you see in this document. They behave like multiline comments
#'  but you can still use regular comments [#] by default. 

#' Reformat Comment [CTRL + SHIFT + /]
#'  If you have a multi-line comment, highlight several lines and use this to
#'  make them all even and within the 80 character per line guide.



## Navigating RStudio ------------------------------------------------------


#' Focus Script [CTRL + 1]
#' Focus Console [CTRL + 2]
#' Focus Help [CTRL + 3]...
#'  These go on and on through 9. They are great at moving around between panes
#'  without having to use your mouse.

#' Zoom Script [CTRL + SHIFT + 1]
#' Zoom Console [CTRL + SHIFT + 2]...
#'  Makes any one of them full screen. Great for checking out a large plot or
#'  an output in the console. Stop fiddling with readjusting the pane sizes! 
#'  Speaking of pane sizes, you can assign hotkeys to focus the left, right, or
#'  center separators so you can adjust pane sizes without using your mouse.

#' Full Screen: [F11]
#'  Space is sanity. Get rid of the toolbars and make best use of your monitor.

