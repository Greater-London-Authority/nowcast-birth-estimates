library(zip)
library(rmarkdown)

if(!dir.exists("plots/maps/")) dir.create("plots/maps/", recursive = TRUE)

# create a zip of the plots folder
zip(zipfile = "plots.zip",
    files = "plots",
    root = "outputs",
    mode = "mirror")

# knit the markdown for checking by a human before it gets uploaded
render("nowcast-birth-estimates-markdown.Rmd")
