################################################################################
# Joshua C. Fjelstul, Ph.D.
# codebookr R package
################################################################################

#' Create dataset documentation
#'
#' This function generates \code{R} documentation for one or more datasets based
#' on a codebook saved as a \code{.csv} file. Whenever you edit the \code{.csv},
#' you can easily regenerate the \code{R} documentation without making the
#' changes in multiple places. This is especially useful when you want to
#' distribute the codebook in multiple formats. This package also provides
#' functions for converting a \code{.csv} codebook to other common formats,
#' including \code{.txt} (plain text), \code{.md} (markdown), \code{.Rmd}
#' (\code{R} markdown), and \code{.tex} (\code{LaTeX}).
#'
#' Running this function generates one \code{.R} file per dataset and saves
#' these files in the folder indicated by the \code{path} argument. If you're
#' developing an \code{R} package, this path should be to the \code{R/} folder.
#' After you run \code{document_data()} to produce an \code{.R} file for each
#' dataset, you can run \code{roxygen2} using \code{devetools::document()} to
#' generate a \code{.Rd} (\code{R} documentation) file for each dataset. These
#' \code{.Rd} files will be saved to the \code{man/} folder, as usual.
#'
#' At minimum, you have to provide the path to a \code{.csv} file that contains
#' a codebook for each dataset and a text file that contains a title a
#' description for each dataset. The text file can be a \code{.txt}, a
#' \code{.md}, or a \code{.Rmd} file.
#'
#' The \code{.csv} file must include a variable called \code{dataset} that
#' indicates the name of each dataset, a variable called \code{variable} that
#' indicates the name of each variable in each dataset, and a variable called
#' \code{description} that includes a description for each variable. Optionally,
#' the \code{.csv} file can include a variable called \code{type} that indicates
#' the type of each variable (e.g., \code{numeric}, \code{string}, \code{dummy},
#' etc.). If this variable is included, the type of the variable will be
#' included in the description in the final documentation file. To format text
#' as code in a variable description, wrap the text in curly brackets or use
#' markdown syntax (i.e., wrap the text in tick marks).
#'
#' The text file (\code{.txt}, \code{.md}, or \code{.Rmd}) should include one
#' heading and one description per dataset. The heading will be used as the
#' title for the documentation in the \code{.R} output file. The datasets must
#' be in the same order as in the \code{.csv} file. The heading should be
#' formatted using markdown syntax (i.e., include at least one \code{#} at the
#' start of the line). The description should follow the heading and can include
#' multiple paragraphs. It is not necessary to include line breaks between
#' paragaphs or before or after titles. To format text as code, you can use
#' markdown syntax (i.e., wrap the text in tick marks).
#'
#' @param path The path to the folder where the output file should be saved. If
#'   you're developing an \code{R} package and you're working directory is set
#'   to the project directory, this argument should be \code{"R/"}.
#' @param codebook_file The path and file for the codebook. The codebook must be
#'   a \code{.csv} file.
#' @param markdown_file The path and file for a markdown file that contains a
#'   header and description for each dataset. The markdown file must be a
#'   \code{.txt}, \code{.md}, or \code{.Rmd} file.
#' @param datasets_file The path and file for information about the datasets.
#'   The file must be a \code{.csv} file.
#' @param author Optional. A string or string vector indicating the name of the
#'   package author(s). If provided, these names will be included in the header
#'   of each \code{.R} file produced.
#' @param package Optional. A string indicating the name of the package that the
#'   data will be distributed in. If provided, the name of the package will be
#'   included in the header of each \code{.R} file produced.
#' @export
document_data <- function(path, variables_file, datasets_file = NULL, markdown_file = NULL, author = NULL, package = NULL) {

  # read in data
  codebook <- read.csv(variables_file, stringsAsFactors = FALSE)

  # parse markdown
  if (!is.null(markdown_file)) {
    markdown <- parse_markdown(markdown_file)
    titles <- markdown$titles
    descriptions <- markdown$descriptions
  } else {
    dataset_info <- read.csv(datasets_file, stringsAsFactors = FALSE)
    titles <- dataset_info$label
    descriptions <- dataset_info$description
  }

  # the names of the datasets
  datasets <- unique(codebook$dataset)

  # the number of datasets
  n <- length(datasets)

  # author
  if(!is.null(author)) {
    author <- stringr::str_c("# ", author)
  }

  # package
  if(!is.null(package)) {
    package <- stringr::str_c("# ", package, " R package")
  }

  # make an empty list to store documents
  documents <- list()

  # loop through each dataset
  for(i in 1:n) {

    # metadata for dataset
    metadata <- dplyr::filter(codebook, dataset == datasets[i])
    metadata$description <- stringr::str_replace_all(metadata$description, "\\{(.*?)\\}", "\\\\code\\{\\1\\}")

    # file header
    header <- c(
      "################################################################################",
      author,
      package,
      "# automatically generated by the codebookr R package",
      "################################################################################",
      ""
    )

    # title
    title <- titles[i]

    # description
    description <- descriptions[[i]]
    description <- stringr::str_c(description, collapse = "\n")

    # format
    format <- stringr::str_c("@format A data frame with ", nrow(metadata), " variables:")

    # variables
    variables <- stringr::str_c(
      "\\item{", metadata$variable, "}",
      "{", stringr::str_to_title(metadata$type), ". ", metadata$description, "}"
    )

    # describe
    describe <- c("\\describe{", variables, "}")
    describe <- stringr::str_c(describe, collapse = "\n")

    # source
    source <- NULL
    if("source" %in% names(data)) {
      source <- stringr::str_c("@source ", data$source[i])
    }

    # dataset
    dataset <- stringr::str_c("\"", datasets[i], "\"")

    # file footer
    footer <- c(
      "",
      "################################################################################",
      "# end R script",
      "################################################################################",
      ""
    )

    # comments
    comments <- stringr::str_c(
      title, "\n\n", description, "\n\n", format, "\n", describe
    )
    comments <- reflow_comment(comments)

    # build document
    document <- c(
      header,
      comments,
      dataset,
      footer
    )

    # add to documents
    documents[[i]] <- document
  }

  # save documents
  for(i in 1:n) {

    # file output
    output <- documents[[i]]

    # file name
    file <- stringr::str_c(datasets[i], ".R")

    # write R file to working directory
    writeLines(output, stringr::str_c(path, file))
  }

  # message
  cat("documents saved to working directory")
}

################################################################################
# end R script
################################################################################
