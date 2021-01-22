###########################################################################
# Joshua C. Fjelstul, Ph.D.
# codebookr R package
###########################################################################

##################################################
# parse_markdown
##################################################

parse_markdown <- function(file) {

  # read in file
  markdown <- readLines(file)

  # remove blank lines
  markdown <- stringr::str_squish(markdown)
  markdown <- markdown[markdown != ""]

  # convert to a tibble
  markdown <- dplyr::tibble(text = markdown)

  # line type
  markdown$type <- "paragraph"
  markdown$type[stringr::str_detect(markdown$text, "^#[^#]")] <- "heading"
  markdown$type[stringr::str_detect(markdown$text, "^##[^#]")] <- "subheading"

  # clean text
  markdown$text <- stringr::str_replace(markdown$text, "^#+ *", "")

  # code dataset variable
  markdown$dataset <- markdown$text
  markdown$dataset[markdown$type != "heading"] <- NA
  markdown <- tidyr::fill(markdown, dataset)
  markdown <- dplyr::filter(markdown, text != dataset)

  # return parsed markdown
  return(markdown)
}

##################################################
# inject
##################################################

inject <- function(x, z, at) {
  a <- x[1:(at - 1)]
  b <- x[(at + 1):length(x)]
  out <- c(a, z, b)
  return(out)
}

##################################################
# format_code
##################################################

format_code <- function(x) {
  x <- stringr::str_replace_all(x, "[{]", "\\\\code{")
  return(x)
}

##################################################
# create_codebook
##################################################

# read in templates
# codebook_template <- readLines("data/templates/codebook-template.tex")
# table_of_contents_template <- readLines("data/templates/table-of-contents-template.tex")
# dataset_template <- readLines("data/templates/dataset-template.tex")
# variable_template <- readLines("data/templates/variable-template.tex")
#
# save(
#   codebook_template,
#   table_of_contents_template,
#   dataset_template,
#   variable_template,
#   file = "R/sysdata.rda"
# )
#

create_codebook  <- function(variables_input, markdown_file, footer_text, title, authors, chip_data_input = NULL, table_of_contents = TRUE, theme_color = "3B86F7") {

  # define pipe function
  # `%>%` <- magrittr::`%>%`

  # parse markdown
  markdown <- parse_markdown(markdown_file)

  # a list of datasets
  datasets <- dplyr::tibble(dataset = unique(variables_input$dataset))

  # loop through datasets
  content <- NULL
  for(i in 1:nrow(datasets)) {

    # duplicate the dataset template
    dataset <- dataset_template

    # inject heading
    heading <- unique(markdown$dataset[markdown$dataset == datasets$dataset[i]])
    # heading <- format_code(heading)
    if(length(heading) > 0) {
      dataset <- stringr::str_replace(dataset, "HEADING", heading)
    }

    # inject subheading
    subheading <- unique(markdown$text[markdown$type == "subheading" & markdown$dataset == datasets$dataset[i]])
    # subheading <- format_code(subheading)
    if(length(subheading) > 0) {
      dataset <- stringr::str_replace(dataset, "SUBHEADING", subheading)
    }

    # inject description
    paragraphs <- markdown$text[markdown$type == "paragraph" & markdown$dataset == datasets$dataset[i]]
    paragraphs <- format_code(paragraphs)
    if(length(paragraphs)) {
      dataset <- inject(dataset, paragraphs, at = which(dataset == "DESCRIPTION"))
    }

    # inject chip data
    if(!is.null(chip_data_input)) {
      chips <- "\\hspace{10pt}"
      chip_data <- dplyr::filter(chip_data_input, dataset == datasets$dataset[i])
      chip_data <- dplyr::select(chip_data, -dataset)
      chip_data <- as.character(chip_data)
      for(j in 1:length(chip_data)) {
        chips <- stringr::str_c(chips, " \\chip{", chip_data[j], "} \\hspace{10pt}")
      }
      chips <- stringr::str_c(chips, " \\vspace{5pt}")
      dataset <- inject(dataset, chips, at = which(dataset == "CHIPS"))
    } else {
      dataset[dataset == "CHIPS"] <- ""
    }

    # get data from input tibble for dataset i
    variables <- variables_input$variable[variables_input$dataset == datasets$dataset[i]]
    descriptions <- variables_input$description[variables_input$dataset == datasets$dataset[i]]

    # clean
    variables <- format_code(variables)
    descriptions <- format_code(descriptions)

    # create items for dataset i
    items <- stringr::str_c("\\item[\\code{", variables, "}] ", descriptions)

    # add items to dataset i template
    dataset <- inject(dataset, items, at = which(dataset == "ITEMS"))

    # add code for dataset i to content list
    content[[i]] <- dataset
  }

  # convert content to a vector
  content <- unlist(content)

  # clean special characters
  content <- stringr::str_replace_all(content, "#", "\\\\#")
  content <- stringr::str_replace_all(content, "_", "\\\\_")

  # inject input into the template
  codebook <- codebook_template
  codebook <- stringr::str_replace(codebook, "COLOR", theme_color)
  codebook <- stringr::str_replace(codebook, "FOOTER", footer_text)
  codebook <- inject(codebook, content, at = which(codebook == "CONTENT"))

  # table of contents
  if(table_of_contents) {
    codebook <- inject(codebook, table_of_contents_template, at = which(codebook == "TABLE"))
  } else {
    codebook[codebook == "TABLE"] <- ""
  }

  # save file
  file <- file("output/output.tex")
  writeLines(codebook, file)
  close(file)
}

##################################################
# test
##################################################

variables_input <- read.csv("data/CJEU_codebook.csv", stringsAsFactors = FALSE)
markdown_file <- "data/CJEU_codebook_content.txt"
chip_data_input <- read.csv("data/dataset_summary.csv", stringsAsFactors = FALSE)

codebook_template <- readLines("data/templates/codebook-template.tex")
table_of_contents_template <- readLines("data/templates/table-of-contents-template.tex")
dataset_template <- readLines("data/templates/dataset-template.tex")
variable_template <- readLines("data/templates/variable-template.tex")



create_codebook(
  variables_input = variables_input,
  markdown_file = markdown_file,
  chip_data_input = chip_data_input,
  footer_text = "Court of Justice of the European Union (CJEU) Dataset",
)

###########################################################################
# end R script
###########################################################################
