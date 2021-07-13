################################################################################
# Joshua C. Fjelstul, Ph.D.
# codebookr R package
################################################################################

# view example data
View(codebookr::euip_datasets)
View(codebookr::euip_variables)

# create a codebook
codebookr::create_codebook(
  file_path = "example/codebook/codebook.tex",
  datasets_input = euip_datasets,
  variables_input = euip_variables,
  title_text = "The European Union Infringement Procedure \\\\ (EUIP) Database",
  version_text = "1.0",
  footer_text = "The EUIP Database Codebook \\hspace{5pt} | \\hspace{5pt} Joshua C. Fjelstul, Ph.D.",
  author_names = "Joshua C. Fjelstul, Ph.D.",
  theme_color = "#4D9FEB",
  heading_font_size = 30,
  subheading_font_size = 10,
  title_font_size = 16,
  table_of_contents = TRUE,
  include_variable_type = TRUE
)

# document the dataset
codebookr::document_data(
  file_path = "example/R/",
  datasets_input = euip_datasets,
  variables_input = euip_variables,
  include_variable_type = TRUE,
  author = "Joshua C. Fjelstul, Ph.D.",
  package = "euip"
)

# create the documentation for your R package
# devtools::document()

################################################################################
# end R script
################################################################################
