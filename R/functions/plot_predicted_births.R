library(scales)
library(ggplot2)
library(gglaplot)
library(lubridate)


plot_predicted_births_pts <- function(sel_code, pred_births,
                                  dt_actual_start = as.Date("2018-06-30"),
                                  dt_pred_start = as.Date("2020-06-30"),
                                  d_breaks = "3 months",
                                  exc_actual_line = FALSE){

  pbirths <- pred_births %>%
    filter(gss_code == sel_code) %>%
    filter(year_ending_date >= dt_actual_start) %>%
    filter(!(type == "predicted" & year_ending_date < dt_pred_start))

  abirths <- pbirths %>%
    filter(type == "actual")

  if(exc_actual_line) pbirths <- filter(pbirths, type == "predicted")

  sel_name <- unique(pbirths$gss_name)

  plt_births <- pbirths %>%
    ggplot(aes(x = year_ending_date, y = annual_births, colour = type, ymin = ci_lower, ymax = ci_upper, fill = type)) +
    theme_gla() +
    ggla_line() +
    geom_ribbon(alpha = 0.2) +
    geom_point(data = abirths, shape = 19, size = 3) +
    scale_x_date(date_breaks = d_breaks, labels = label_date_short(),
                 expand = c(0, 0)) +
    scale_y_continuous(n.breaks = 8) +
    theme(plot.margin = unit(c(1,2,1,1), "lines")) +
    labs(title = "Actual and predicted annual live births",
         subtitle = sel_name,
         caption = "Annual live births by date of year ending\nSources: ONS birth estimates for calendar and mid-year periods; GLA birth estimates modelled from patient registration data")

  return(plt_births)
}

plot_predicted_births_indexed <- function(sel_code, pred_births,
                                      dt_actual_start = as.Date("2011-06-30"),
                                      dt_pred_start = as.Date("2022-01-01"),
                                      dt_relative_to = as.Date("2019-07-01"),
                                      d_breaks = "1 year",
                                      exc_actual_line = FALSE){

  baseline_births <- pred_births %>%
    filter(gss_code == sel_code) %>%
    filter(type == "actual") %>%
    filter(year_ending_date == dt_relative_to) %>%
    pull(annual_births)

  pbirths <- pred_births %>%
    filter(gss_code == sel_code) %>%
    filter(year_ending_date >= dt_actual_start) %>%
    filter(!(type == "predicted" & year_ending_date < dt_pred_start))

  pbirths_relative <- pbirths %>%
    mutate(value = 100 * annual_births/baseline_births,
           ci_lower = 100 * ci_lower/baseline_births,
           ci_upper = 100 * ci_upper/baseline_births)

  abirths_relative <- pbirths_relative %>%
    filter(type == "actual")

  if(exc_actual_line) pbirths_relative <- filter(pbirths_relative, type == "predicted")

  sel_name <- unique(pbirths$gss_name)

  str_index_date <- paste0(month.name[month(dt_relative_to)], " ", year(dt_relative_to))

  plt_births <- pbirths_relative %>%
    ggplot(aes(x = year_ending_date, y = value, colour = type, ymin = ci_lower, ymax = ci_upper, fill = type)) +
    theme_gla() +
    ggla_line() +
    geom_ribbon(alpha = 0.2) +
    geom_point(data = abirths_relative, shape = 19, size = 2) +
    scale_x_date(date_breaks = d_breaks, labels = label_date_short(),
                 expand = c(0, 0)) +
    scale_y_continuous(n.breaks = 8) +
    labs(title = "Actual and predicted annual live births",
         subtitle = paste0(sel_name, " - indexed to ", str_index_date, "\n100 = ", format(as.numeric(baseline_births), nsmall=0, big.mark=","), " births"),
         caption = "Annual live births by date of year ending\n
         Sources: ONS birth estimates for calendar and mid-year periods; GLA birth estimates modelled from patient registration data")


  return(plt_births)
}

plot_predicted_births_line <- function(sel_code, pred_births,
                                      dt_actual_start = as.Date("1992-06-30"),
                                      dt_pred_start = as.Date("2020-06-30"),
                                      d_breaks = "2 years"){

  pbirths <- pred_births %>%
    filter(gss_code == sel_code) %>%
    filter(year_ending_date >= dt_actual_start) %>%
    filter(!(type == "predicted" & year_ending_date < dt_pred_start))

  a_births <- pred_births %>%
    filter(gss_code == sel_code) %>%
    filter(year_ending_date >= dt_actual_start) %>%
    filter(type == "actual")

  sel_name <- unique(pbirths$gss_name)

  plt_births <- a_births %>%
    ggplot(aes(x = year_ending_date, y = annual_births, colour = type, ymin = ci_lower, ymax = ci_upper, fill = type)) +
    theme_gla() +
    ggla_line() +
    geom_ribbon(data = pbirths, alpha = 0.2) +
    scale_x_date(date_breaks = d_breaks, labels = label_date_short(),
                 expand = c(0, 0)) +
    scale_y_continuous(n.breaks = 8) +
    theme(plot.margin = unit(c(1,2,1,1), "lines")) +
    labs(title = "Actual and predicted annual live births",
         subtitle = sel_name,
         caption = "Annual live births by date of year ending\nSources: ONS birth estimates for calendar and mid-year periods; GLA birth estimates modelled from patient registration data")

  return(plt_births)
}
