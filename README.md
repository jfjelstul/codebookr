# codebookr

This R package contains tools for easily generating documentation for datasets. There are two main functions: `create_codebook()` and `document_data()`. The function `create_codebook()` generates `LaTeX` code (a `.tex` file) for a nicely-formatted `.pdf` codebook with a modern, minimalist look. There's an example in the `example/` directory. The function `document_data()` automatically generates `R` documentation for an `R` data package (i.e., an `R` script for each dataset in your project with `roxygen2` comments).

These functions make it easy to produce documentation for a data project. All you have to provide, for both functions, is two `.csv` files, one with some information about each dataset in your project and another with some information about each variable in each dataset. Then, when you go to update your documentation, all you have to do is update the two `.csv` files and re-run these functions. This saves you from having to make the same change in multiple places, which can be a really tedious and error-prone process, especially for large datasets and projects with multiple datasets. 

Example of a codebook made with `codebookr::create_codebook()` using the built-in template: 

<div>
  <img src="https://github.com/jfjelstul/codebookr/blob/master/example/images/cover-page.png?raw=true" width="45%">
  <img src="https://github.com/jfjelstul/codebookr/blob/master/example/images/dataset-page.png?raw=true" width="45%">
</div>

## Installation

You can install the latest development version of the `codebookr` package from GitHub:

```r
# install.packages("devtools")
devtools::install_github("jfjelstul/codebookr")
```

## Citation

If you use data from the `codebookr` package in a project, please cite the package:

> Joshua Fjelstul (2021). codebookr: Tools to Document Datasets in R. R package version 0.1.0.9000.

The `BibTeX` entry for the package is:

```
@Manual{,
  title = {codebookr: Tools to Document Datasets in R},
  author = {Joshua Fjelstul},
  year = {2021},
  note = {R package version 0.1.0.9000},
}
```

## Problems

If you notice an error in the data or a bug in the `R` package, please report it [here](https://github.com/jfjelstul/codebookr/issues).

## Example 1: Creating a PDF Codebook

Creating a nicely-formatted codebooks in `LaTeX` can be a slow and involved process, and doing it well usually requires using a variety of packages, writing custom macros, and using `tikz` and `XeLaTeX`. The `create_codebook()` function in the `codebookr` package automatically creates a `.tex` file for a nicey-formatted codebook that you can compile using `XeLaTeX` based on two data frames that you provide, one with information on each dataset and another with information on each variable in each dataset. The template is appropriate for nearly any kind of data project and the `create_codebook()` function includes some customization options. You can always edit the `.tex` file that is generated to further customize the formatting of the codebook. Using this function saves you from having to translate your documentation to `LaTeX` code. 

The following example shows how I generated the codebook for my [European Union Infringement Procedure (EUIP) Database](https://github.com/jfjelstul/euip). You can include multiple authors by providing a vector of author names for the `author_names` argument. For the `title_text` and `footer_text` arguments, you can also include valid `LaTeX` code, but you have to escape each `\` with an additional `\`. So for example, a line break would be `\\\\`. 

The `dataset_input` data frame must include: (1) a variable called `dataset` that is the name of each dataset, which will be used as the heading for each dataset section; (2) a variable called `label` that is a short label for each dataset (one line), which will be used as the subheading for each dataset section; and (3) a variable called `description` that is a description of each dataset, which will be included before the description of each variable. Text wrapped in braces will be formatted as code. The dataset names should be valid `R` object names. 

The `variables_input` data frame must include: (1) a variable called `dataset`, where each dataset maps exactly to the datasets in the `dataset` variable in the `datasets_input` data frame; and (2) a variable called `description` that is a description of each variable. Text wrapped in braces will be formatted as code. Optionally, the data frame can include a variable called `type` that indicates the type of each variable (e.g., numeric, string, etc.). If this variable is included, and the `include_variable_type` argument is set to `TRUE`, then the variable type will be included at the beginning of each variable description.

```r
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
```

The customization options are covered in the documentation, which you can see by running `?codebookr::create_codebook`. You can request additional customization options [here](https://github.com/jfjelstul/codebookr/issues).

## Example 2: Creating Documentation for an R Data Package

Packaging up a group of datasets into an `R` data package is a great way to keep your data and replication code organized and to share data with colleagues. But writing the documentation can be really tedious. You have to write an `R` script with `roxygen2` comments for each dataset and then build the `.Rd` documentation files for the package, which are stored in the `man/` folder in your package directory, using `devtools::document()`. The function `document_data()` in the `codebookr` package automatically generates an `R` script with `roxygen2` comments for each of the datasets in your project based on two data frames that you provide, one with information on each dataset and another with information on each variable in each dataset. This way, you don't have to write any `roxygen2` comments to document your data. 

The following example shows how I generated the documentation for my `ecio` package, which is an `R` data package for the [European Union Infringement Procedure (EUIP) Database](https://github.com/jfjelstul/euip). The `file_path` should be the path for the `R` folder in your package directory. You can specify the optional `author` and `package` arguments to include the name of the author(s) and the name of the package in the `R` scripts that are generated. 

As with the `create_codebook()` function, the `dataset_input` data frame must include: (1) a variable called `dataset` that is the name of each dataset, which will be used as the heading for each dataset section; (2) a variable called `label` that is a short label for each dataset (one line), which will be used as the subheading for each dataset section; and (3) a variable called `description` that is a description of each dataset, which will be included before the description of each variable. The dataset names should be valid `R` object names. Text wrapped in braces will be formatted as code. 

The `variables_input` data frame must include: (1) a variable called `dataset`, where each dataset maps exactly to the datasets in the `dataset` variable in the `datasets_input` data frame; and (2) a variable called `description` that is a description of each variable. Optionally, the data frame can include a variable called `type` that indicates the type of each variable (e.g., numeric, string, etc.). If this variable is included, and the `include_variable_type` argument is set to `TRUE`, then the variable type will be included at the beginning of each variable description. Text wrapped in braces will be formatted as code. 

```r
# view example data
View(codebookr::euip_datasets)
View(codebookr::euip_variables)

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
```

When you run the `document_data()` function, one `R` script with `roxygen2` comments will be created for each dataset in your project, and these files will be saved to the `R` folder in your project (unless you specify otherwise). Then, you just need to run `devtools::document()` to generate the `.Rd` that contain the documentation for your data package. This allows your users to look up a dataset and read the variable descriptsions by running `?` followed by the dataset name. 
