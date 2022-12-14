# lab 4

#' clean the lab data sheet
#'
#' this function is form specific
#' may not appliable if the form changes
#'
#' @param raw a raw dataframe from reading the excel
#' @return a cleaned version for computation
#' @export
clean_lab4_excel <- function(raw) {
    clean <- raw[, !(names(raw) %in% c("Grp. Name", "Mean", "SD", "SE"))]
    clean <- clean[rowSums(is.na(clean)) == 0, ]
    class(clean) <- c("lab4", class(clean))
    clean
}

#' add mean, sd, se to lab data
#' @param data a cleaned dataframe (from clean_lab4_excel)
#' @return mean, standard deviation, standard error
#' @examples
#' summary(clean_lab4_excel(raw_df))
#' @export
summary.lab4 <- function(data) {
    # compute the intermediate data
    memo <- data.frame(
        Mean = rowMeans(data),
        SD = apply(data, 1, sd)
    )
    memo$SE <- memo$SD / sqrt(ncol(data))
    list(
        data = round(memo, 2),
        df = 2 * ncol(data) - 2
    )
}

#' Test for a Treatment
#'
#' t test for a treatment by given compoents
#'
#' @param memo a cleaned dataframe (from summerize_lab4)
#' @param treatement string the name of this treatement
#' @param components list of string components names to compare
#' @param  alpha float Significance Level
#' @return a complete table of test results
#' @examples
#' summ <- summary(clean_lab4_excel(raw_df))
#' test_treatment(summ$data, treatments[i], components, summ$df)
#' @export
test_treatment <- function(memo, treatement, components, df, alpha = 0.05) {
    # critical value
    crit <- qt(1 - alpha, df)

    # t test
    l <- length(components)
    result <- data.frame(
        Treatment = rep(treatement, l),
        Component = components,
        Null = rep(NA, l),
        Alt = rep(NA, l),
        t.val = rep(NA, l),
        Reject = rep(NA, l)
    )
    row_odd <- seq_len(nrow(memo)) %% 2
    morph1 <- memo[row_odd == 1, ]
    morph2 <- memo[row_odd == 0, ]

    for (i in 1:3) {
        mean_g <- morph1$Mean[i]
        mean_yg <- morph2$Mean[i]
        sd_g <- morph1$SD[i]
        sd_yg <- morph2$SD[i]

        t <- abs(mean_g - mean_yg) /
            sqrt(sd_g^2 / 12 + sd_yg^2 / 12)
        result[i, ]$Null <- paste(mean_g, "=", mean_yg, sep = " ")
        result[i, ]$Alt <- paste(mean_g, "!=", mean_yg, sep = " ")
        result[i, ]$t.val <- t
        result[i, ]$Reject <- t > crit
    }
    result
}
