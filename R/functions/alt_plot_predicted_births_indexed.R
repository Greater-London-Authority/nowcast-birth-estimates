library(scales)
library(ggplot2)
library(lubridate)

plot_predicted_births_indexed <- function(sel_cd, births_all,
                                          dt_plot_start = as.Date("2011-06-30"),
                                          dt_relative_to = as.Date("2019-07-01"),
                                          d_breaks = "1 year",
                                          pt_size = 3){

  baseline_births <- births_all %>%
    filter(gss_code == sel_cd) %>%
    filter(date == dt_relative_to) %>%
    pull(annual_births)

  births_df <- births_all %>%
    filter(gss_code == sel_cd) %>%
    filter(date >= dt_plot_start) %>%
    mutate(annual_births = 100 * annual_births/baseline_births,
           interval_lower = 100 * interval_lower/baseline_births,
           interval_upper = 100 * interval_upper/baseline_births)

  pbirths <- births_df %>%
    filter(type == "predicted")

  abirths <- births_df %>%
    filter(type == "actual")

  ibirths <- births_df %>%
    filter(type2 == "past") %>%
    mutate(type = "interpolated")

  sel_name <- unique(births_df$gss_name)

  str_index_date <- paste0(month.name[month(dt_relative_to)], " ", year(dt_relative_to))

  plt_births <- pbirths %>%
    ggplot(aes(x = date, y = annual_births, colour = type, ymin = interval_lower, ymax = interval_upper, fill = type)) +
    theme_minimal() +
    geom_line(linewidth = 1.1) +
    geom_ribbon(alpha = 0.2) +
    geom_line(data = ibirths, alpha = 0.4, linewidth = 1.1) +
    geom_point(data = abirths, shape = 18, size = pt_size) +
    scale_x_date(date_breaks = d_breaks, labels = label_date_short(),
                 expand = c(0, 0)) +
    scale_y_continuous(n.breaks = 8) +
    theme(plot.margin = unit(c(1,2,1,1), "lines")) +
    theme(legend.position = "top") +
    ylab("") +
    xlab("") +
    labs(title = "Actual and predicted annual live births",
         subtitle = paste0(sel_name, " - indexed to ", str_index_date, ", 100 = ", format(as.numeric(baseline_births), nsmall=0, big.mark=","), " births"),
         caption = "Annual live births by date of year ending\n
         Sources: ONS birth estimates for calendar and mid-year periods; GLA birth estimates modelled from patient registration data")

  return(plt_births)
}

