################################################################################
# Joshua C. Fjelstul, Ph.D.
# codebookr R package
################################################################################

reflow_comment <- function(code) {

  # set up the while loop
  remaining_code <- code
  max_length <- 77
  current_length <- nchar(code)
  new_code <- NULL

  # loop through the comment
  while(current_length > max_length | stringr::str_detect(remaining_code, "\n")) {

    # calculate the location of spaces
    locations <- stringr::str_locate_all(remaining_code, " |\n")
    locations <- as.data.frame(locations)
    locations <- locations$start

    # calculate the location of the next line break
    next_line_break <- stringr::str_locate(remaining_code, "\n")
    next_line_break <- as.data.frame(next_line_break)
    next_line_break <- next_line_break$start

    # calculate where to split the line
    break_point <- locations - max_length
    break_point <- break_point[break_point < 0]
    break_point <- break_point[break_point == max(break_point)]
    break_point <- break_point + max_length
    break_point <- min(break_point, next_line_break)

    # split the text
    new_line <- stringr::str_sub(remaining_code, start = 0, end = break_point - 1)
    remaining_code <- stringr::str_sub(remaining_code, start = break_point + 1)

    # add text to the new text
    new_code <- c(new_code, new_line)

    # recalculate the length of the remaining text
    current_length <- nchar(remaining_code)
  }

  # add the remining text to the new comment
  new_code <- c(new_code, remaining_code)

  # clean spaces
  new_code <- stringr::str_squish(new_code)

  # format comment
  new_code <- stringr::str_c("#' ", new_code)

  # return new comment
  return(new_code)
}

################################################################################
# end R script
################################################################################
