################################################################################
# Joshua C. Fjelstul, Ph.D.
# codebookr R package
################################################################################

#' Create a PDF codebook
#'
#' This function generates \code{LaTeX} code (a \code{.tex} file) for a
#' nicely-formatted PDF codebook. You need to provide a data frame with a
#' description of each dataset and a data frame with a description of each
#' variable. Once you've generated the \code{.tex} file, you can compile the PDF
#' using any \code{LaTeX} editor. You need to compile the \code{.tex} file using
#' \code{XeLaTeX} instead of \code{LaTeX}. You will need to compile the PDF
#' twice. You need to have the \code{roboto} font installed, which you can
#' download for free on Google Fonts
#' (\code{https://fonts.google.com/specimen/Roboto}). You can further customize
#' the \code{.tex} file that is generated. Please report bugs and request
#' features at \code{https://github.com/jfjelstul/codebookr/issues}.
#'
#' @param datasets_input A data frame containing information on each dataset.
#'   This data frame must include: (1) a variable called \code{dataset} that is
#'   the name of each dataset, which will be used as the heading for each
#'   dataset section; (2) a variable called \code{label} that is a short label
#'   for each dataset (one line), which will be used as the subheading for each
#'   dataset section; and (3) a variable called \code{description} that is a
#'   description of each dataset, which will be included before the description
#'   of each variable. Text wrapped in braces will be formatted as code. The
#'   dataset names should be valid \code{R} object names.
#' @param variables_input A data frame containing infromation on each variable.
#'   This data frame must include: (1) a variable called \code{dataset}, where
#'   each dataset maps exactly to the datasets in the \code{dataset} variable in
#'   the \code{datasets_input} data frame; and (2) a variable called
#'   \code{description} that is a description of each variable. Text wrapped in
#'   braces will be formatted as code. Optionally, the data frame can include a
#'   variable called \code{type} that indicates the type of each variable (e.g.,
#'   numeric, string, etc.). If this variable is included, and the
#'   \code{include_variable_type} argument is set to \code{TRUE}, then the
#'   variable type will be included at the beginning of each variable
#'   description.
#' @param file_path The path and file for the \code{.tex} file that will be
#'   created. You need to include the \code{.tex} extension in the file name.
#' @param title_text A string containing the title for the title page.
#' @param version_text A string containing the version number for the title page
#'   (e.g., \code{1.0}).
#' @param footer_text A string containing the text for the footer at the bottom
#'   of each page. This string can include valid \code{LaTeX} code, but you have
#'   to escape the \code{\} with another \code{\}. For example, to inculde some
#'   horizontal space, you could include \code{\\hspace{5pt}}.
#' @param author_names A string vector containing the names of the
#'   authors for the title page or a string if there is one author.
#' @param table_of_contents A logical value indicating whether to include a
#'   table of contents.
#' @param include_variable_type A logical value indicating whether to include
#'   the type of the variable in the variable description. The
#'   \code{variables_input} data frame must have a variable called \code{type}
#'   or you will get an error.
#' @param theme_color A string indicating the color to use. The color should be
#'   a valid hex code, including a leading \code{#}. If you don't provide a
#'   valid hex code, your \code{LaTeX} compiler will produce an error (but this
#'   function will not).
#' @param heading_font_size The size of the font for the heading for each
#'   dataset section (i.e., the name of the dataset, contained in the
#'   \code{dataset} variable in the \code{datasets_input} data frame). You
#'   should adjust the font size to make sure your text fits.
#' @param subheading_font_size The size of the font for the subheading for each
#'   dataset section (i.e., the short label for the dataset, contained in the
#'   \code{label} variable in the \code{datasets_input} data frame). You should
#'   adjust the font size to make sure your text fits.
#' @param title_font_size The size of the font for the title on the title page.
#'   You should adjust the font size to make sure your text fits.
#' @export
create_codebook  <- function(
  file_path,
  datasets_input, variables_input,
  title_text, version_text, footer_text, author_names,
  table_of_contents = TRUE, include_variable_type = FALSE,
  theme_color = "#3B86F7",
  title_font_size = 16, heading_font_size = 35, subheading_font_size = 12
) {

  # loop through datasets
  content_code <- NULL
  for(i in 1:nrow(datasets_input)) {

    # duplicate the dataset template
    dataset_code <- dataset_template

    # inject heading
    dataset_code <- stringr::str_replace(dataset_code, "HEADING", datasets_input$dataset[i])

    # inject subheading
    dataset_code <- stringr::str_replace(dataset_code, "SUBHEADING", datasets_input$label[i])

    # inject heading font size
    dataset_code <- stringr::str_replace(dataset_code, "HEADING_FONT_SIZE", as.character(heading_font_size))

    # inject subheading font size
    dataset_code <- stringr::str_replace(dataset_code, "SUBHEADING_FONT_SIZE", as.character(subheading_font_size))

    # inject description
    dataset_code <- inject(dataset_code, datasets_input$description[i], at = which(dataset_code == "DATASET_DESCRIPTION"))

    # inject chip data
    # if(!is.null(chip_data_input)) {
    #   chips <- "\\hspace{10pt}"
    #   chip_data <- dplyr::filter(chip_data_input, dataset == datasets$dataset[i])
    #   chip_data <- dplyr::select(chip_data, -dataset)
    #   chip_data <- as.character(chip_data)
    #   for(j in 1:length(chip_data)) {
    #     chips <- stringr::str_c(chips, " \\chip{", chip_data[j], "} \\hspace{10pt}")
    #   }
    #   chips <- stringr::str_c(chips, " \\vspace{5pt}")
    #   dataset <- inject(dataset, chips, at = which(dataset == "CHIPS"))
    # } else {
    #   dataset[dataset == "CHIPS"] <- ""
    # }

    # get data from input tibble for dataset i
    variable_names <- variables_input$variable[variables_input$dataset == datasets_input$dataset[i]]
    variable_descriptions <- variables_input$description[variables_input$dataset == datasets_input$dataset[i]]

    # format variable names
    variable_names <- format_code(variable_names)

    # variable type
    if (!is.null(variables_input$type)) {
      if (include_variable_type) {
        prefix <- variables_input$type[variables_input$dataset == datasets_input$dataset[i]]
        prefix <- stringr::str_c("\\code{", prefix, "}")
        variable_descriptions <- stringr::str_c(prefix, "\\hspace{5pt}", format_code(variable_descriptions))
      }
    } else {
      variable_descriptions <- format_code(variable_descriptions)
    }

    # create items for dataset i
    items <- stringr::str_c("\\item[\\code{", variable_names, "}] ", variable_descriptions)

    # add items to dataset i template
    dataset_code <- inject(dataset_code, items, at = which(dataset_code == "ITEMS"))

    # add code for dataset i to content list
    content_code[[i]] <- dataset_code
  }

  # convert content to a vector
  content_code <- unlist(content_code)

  # clean special characters
  content_code <- stringr::str_replace_all(content_code, "#", "\\\\#")
  content_code <- stringr::str_replace_all(content_code, "_", "\\\\_")

  # inject input into the template
  codebook_code <- codebook_template

  # color
  codebook_code <- stringr::str_replace(codebook_code, "COLOR", stringr::str_remove(theme_color, "#"))

  # footer text
  footer_text <- stringr::str_replace_all(footer_text, "\\\\", "\\\\\\\\")
  codebook_code <- stringr::str_replace_all(codebook_code, "FOOTER_TEXT", footer_text)

  # title
  title_text <- stringr::str_replace_all(title_text, "\\\\", "\\\\\\\\")
  codebook_code <- stringr::str_replace(codebook_code, "TITLE_TEXT", title_text)

  # title font size
  codebook_code <- stringr::str_replace(codebook_code, "TITLE_FONT_SIZE", as.character(title_font_size))

  # version
  codebook_code <- stringr::str_replace(codebook_code, "VERSION_TEXT", version_text)

  # authors
  author_names <- stringr::str_c(author_names, collapse = "\\\\\\\\[0.75em]")
  codebook_code <- stringr::str_replace(codebook_code, "AUTHOR_NAMES", author_names)

  # content
  codebook_code <- inject(codebook_code, content_code, at = which(codebook_code == "CONTENT"))

  # table of contents
  if(table_of_contents) {
    codebook_code <- inject(codebook_code, table_of_contents_template, at = which(codebook_code == "TABLE_OF_CONTENTS"))
  } else {
    codebook_code[codebook_code == "TABLE_OF_CONTENTS"] <- ""
  }

  # save file
  file_path <- file(file_path)
  writeLines(codebook_code, file_path)
  close(file_path)
}

################################################################################
# end R script
################################################################################
