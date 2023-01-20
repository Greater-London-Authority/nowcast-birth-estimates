library(scales)
library(ggplot2)
library(gglaplot)
library(lubridate)

plot_predicted_births_pts <- function(sel_codes, pred_births,
                                      dt_actual_start = as.Date("2018-06-30"),
                                      d_breaks = "3 months",
                                      exc_actual_line = FALSE,
                                      pt_size = 3){

  pbirths <- pred_births %>%
    filter(gss_code %in% sel_codes) %>%
    filter(date >= dt_actual_start)

  abirths <- pbirths %>%
    filter(type == "actual")

  if(exc_actual_line) pbirths <- filter(pbirths, type == "predicted")

  sel_name <- unique(pbirths$gss_name)

  plt_births <- pbirths %>%
    ggplot(aes(x = date, y = annual_births, colour = type, ymin = interval_lower, ymax = interval_upper, fill = type)) +
    theme_gla(free_y_facets = TRUE) +
    ggla_line() +
    geom_ribbon(alpha = 0.2) +
    geom_point(data = abirths, shape = 19, size = pt_size) +
    scale_x_date(date_breaks = d_breaks, labels = label_date_short(),
                 expand = c(0, 0)) +
    scale_y_continuous(n.breaks = 8) +
    theme(plot.margin = unit(c(1,2,1,1), "lines")) +
    labs(title = "Actual and predicted annual live births",
         subtitle = sel_name,
         caption = "Annual live births by date of year ending\nSources: ONS birth estimates for calendar and mid-year periods; GLA birth estimates modelled from patient registration data")

  return(plt_births)
}
