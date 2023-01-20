library(scales)
library(ggplot2)
library(gglaplot)
library(lubridate)

plot_predicted_births_indexed <- function(sel_codes, pred_births,
                                          dt_actual_start = as.Date("2011-06-30"),
                                          dt_relative_to = as.Date("2019-07-01"),
                                          d_breaks = "1 year",
                                          exc_actual_line = FALSE){

  baseline_births <- pred_births %>%
    filter(gss_code %in% sel_codes) %>%
    filter(type == "actual") %>%
    filter(date == dt_relative_to) %>%
    pull(annual_births)

  pbirths <- pred_births %>%
    filter(gss_code %in% sel_codes) %>%
    filter(date >= dt_actual_start)

  pbirths_relative <- pbirths %>%
    mutate(value = 100 * annual_births/baseline_births,
           interval_lower = 100 * interval_lower/baseline_births,
           interval_upper = 100 * interval_upper/baseline_births)

  abirths_relative <- pbirths_relative %>%
    filter(type == "actual")

  if(exc_actual_line) pbirths_relative <- filter(pbirths_relative, type == "predicted")

  sel_name <- unique(pbirths$gss_name)

  str_index_date <- paste0(month.name[month(dt_relative_to)], " ", year(dt_relative_to))

  plt_births <- pbirths_relative %>%
    ggplot(aes(x = date, y = value, colour = type, ymin = interval_lower, ymax = interval_upper, fill = type)) +
    theme_gla() +
    ggla_line() +
    geom_ribbon(alpha = 0.2) +
    geom_point(data = abirths_relative, shape = 19, size = 2) +
    scale_x_date(date_breaks = d_breaks, labels = label_date_short(),
                 expand = c(0, 0)) +
    scale_y_continuous(n.breaks = 8) +
    theme(plot.margin = unit(c(1,2,1,1), "lines")) +
    labs(title = "Actual and predicted annual live births",
         subtitle = paste0(sel_name, " - indexed to ", str_index_date, "\n100 = ", format(as.numeric(baseline_births), nsmall=0, big.mark=","), " births"),
         caption = "Annual live births by date of year ending\n
         Sources: ONS birth estimates for calendar and mid-year periods; GLA birth estimates modelled from patient registration data")

  return(plt_births)
}
