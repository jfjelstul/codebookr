################################################################################
# Joshua C. Fjelstul, Ph.D.
# ecio R package
# automatically generated by the codebookr R package
################################################################################

#' Decision-level time-series data
#' 
#' This dataset includes aggregated data on the number of decisions per stage
#' of the infringement procedure per year (time-series data). There is one
#' observation per year per decision stage (2002-2020).
#' 
#' @format A data frame with 5 variables:
#' \describe{
#' \item{key_id}{\\code\{numeric\}. An ID number that uniquely identifies each
#' observation in the dataset. }
#' \item{year}{\\code\{numeric\}. The year the decision was issued by the
#' Commission.}
#' \item{decision_stage_id}{\\code\{numeric\}. An ID number that uniquely
#' identifies each decision stage in the infringement procedure. Coded
#' \code{1} for letters of formal notice under Article 258 of the Treaty on
#' the Functioning of the European Union (TFEU), coded \code{2} for reasoned
#' opinions under Article 258, coded \code{3} for referrals to the Court under
#' Article 258, coded \code{4} for letters of formal notice under Article 260,
#' coded \code{5} for reasoned opinions under Article 260, and coded \code{6}
#' for referrals to the Court under Article 261}
#' \item{decision_stage}{\\code\{string\}. The decision stage of the
#' infringement procedure. Possible values include: \code{Letter of formal
#' notice (Article 258)}, \code{Reasoned opinion (Article 259)},
#' \code{Referral to the Court (Article 258)}, \code{Letter of formal notice
#' (Article 260)}, \code{Reasoned opinion (Article 260)}, and \code{Referral
#' to the Court (Article 260)}. }
#' \item{count_decisions}{\\code\{numeric\}. A count of the number of
#' decisions made by the Commission in infringement cases at this level of
#' aggregation.}
#' }
"decisions_ts"

################################################################################
# end R script
################################################################################

