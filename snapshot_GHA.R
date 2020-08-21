library(medrxivr)
library(dplyr)

df <- medrxivr::mx_api_content()

df$link <- gsub("https://www.medrxiv.org", "", df$link_page)
df$pdf <- gsub("https://www.medrxiv.org", "", df$link_pdf)

df <- df %>%
  dplyr::select(-c("link_page","link_pdf"))

# Save data
write.csv(df,
          "snapshot.csv",
          fileEncoding = "UTF-8",
          row.names = FALSE)

current_time <- format(Sys.time(), "%Y-%m-%d %H:%M")

writeLines(current_time, "timestamp.txt")