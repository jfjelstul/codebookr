################################################################################
# Joshua C. Fjelstul, Ph.D.
# codebookr R package
################################################################################

parse_markdown <- function(file) {

  # define pipe
  `%>%` <- magrittr::`%>%`

  # read in file
  markdown <- suppressWarnings(readLines(file))

  # remove blank lines
  markdown <- stringr::str_squish(markdown)
  markdown <- markdown[markdown != ""]

  # convert to a tibble
  markdown <- dplyr::tibble(text = markdown)

  # clean code
  markdown$text <- stringr::str_replace_all(markdown$text, "`(.*?)`", "\\\\code\\{\\1\\}")

  # line type
  markdown$type <- "paragraph"
  markdown$type[stringr::str_detect(markdown$text, "^#")] <- "heading"

  # clean text
  markdown$text <- stringr::str_replace(markdown$text, "^#+ *", "")

  # code dataset variable
  markdown$heading_id <- NA
  markdown$heading_id[markdown$type == "heading"] <- 1:sum(markdown$type == "heading")
  markdown <- tidyr::fill(markdown, heading_id)

  # titles
  titles <- markdown$text[markdown$type == "heading"]

  # descriptions
  descriptions <- list()
  for(i in 1:length(unique(markdown$heading_id))) {
    descriptions[[i]] <- markdown$text[markdown$type == "paragraph" & markdown$heading_id == i]
  }

  # output
  output <- list(
    titles = titles,
    descriptions = descriptions
  )

  # return parsed markdown
  return(output)
}

################################################################################
# end R script
################################################################################
