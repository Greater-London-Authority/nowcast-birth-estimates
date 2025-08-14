library(scales)
library(ggplot2)
library(lubridate)

plot_predicted_births <- function(sel_cd, births_all,
                                  dt_plot_start = as.Date("2016-06-30"),
                                  d_breaks = "3 months",
                                  pt_size = 3){

  births_df <- births_all %>%
    filter(gss_code == sel_cd) %>%
    filter(date >= dt_plot_start)

  pbirths <- births_df %>%
    filter(type == "predicted")

  abirths <- births_df %>%
    filter(type == "actual")

  ibirths <- births_df %>%
    filter(type2 == "past") %>%
    mutate(type = "interpolated")

  sel_name <- unique(births_df$gss_name)

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
         subtitle = sel_name,
         caption = "Annual live births by date of year ending\nSources: ONS birth estimates for calendar and mid-year periods; GLA birth estimates modelled from patient registration data")

  return(plt_births)
}
