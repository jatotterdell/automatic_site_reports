library(rmarkdown, warn.conflicts = FALSE)
suppressPackageStartupMessages(library(here))
suppressPackageStartupMessages(library(tidyverse))
library(redcapAPI, warn.conflicts = FALSE)
library(lubridate, warn.conflicts = FALSE)

# Get the data as of today
rcon <- redcapAPI::redcapConnection(
  url = 'https://redcap.telethonkids.org.au/redcap/api/',
  token = Sys.getenv("AUTOMATIC_TOKEN")
)
current_data <- redcapAPI::exportRecords(rcon) %>%
  as_tibble() %>%
  mutate(
    date_vaccine_due = as_date(date_vaccine_due),
    expected_date_sms_sent = as_date(expected_date_sms_sent),
    actual_date_sms_sent = as_date(actual_date_sms_sent),
    date_of_vaccination_administration = as_date(date_of_vaccination_administration)
  )
# current_data_path <- here("data/AUTOMATIC_DATA_2021-02-25_0810.csv")
# current_data      <- read_csv(current_data_path)
current_sites     <- sort(unique(current_data$clinic_id))

current_dir <- paste0("site_reports/", gsub("-", "", Sys.Date()))
if(!dir.exists(current_dir)) {
  dir.create(current_dir)
}

# Site specific report
for(site in current_sites) {
  cat("Running report for", site, "\n")
  rmarkdown::render(
    "site_reports/site_report.Rmd",
    output_file = paste0(site, ".pdf"),
    output_dir = current_dir,
    params = list(data = current_data, site = site),
    quiet = TRUE)
}

# Overall report
cat("Running report for all sites\n")
rmarkdown::render(
  "site_reports/site_report.Rmd",
  output_file = "_ALL.pdf",
  output_dir = current_dir,
  params = list(data = current_data, site = current_sites),
  quiet = TRUE)
