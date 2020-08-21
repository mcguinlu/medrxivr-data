library(jsonlite) # A Robust, High Performance JSON Parser and Generator for R
library(dplyr) # A Grammar of Data Manipulation # A Grammar of Data Manipulation
library(stringr) # Simple, Consistent Wrappers for Common String Operations
library(rvest) # Easily Harvest (Scrape) Web Pages
library(here) # A Simpler Way to Find Your Files
library(pushoverr) # Send Push Notifications using Pushover
library(readr) # Read Rectangular Text Data
library(tidyr) # Tidy Messy Data
library(git2r) # Provides Access to Git Repositories
library(dplyr) # A Grammar of Data Manipulation # A Grammar of Data Manipulation
library(utf8) # Unicode Text Processing


# set working directory
setwd("C:/Users/lm16564/OneDrive - University of Bristol/Documents/rrr/medrxivr-data")

# Read in credentials
PUSHOVER_USER <- readLines("keys/PUSHOVER_USER.txt")
PUSHOVER_APP <- readLines("keys/PUSHOVER_APP.txt")
GITHUB_USER <- readLines("keys/GITHUB_USER.txt")
GITHUB_PASS <- readLines("keys/GITHUB_PASS.txt")


# Get count and define empty dataframe
today <- Sys.Date()

link <- paste0("https://api.biorxiv.org/details/medrxiv/2019-06-01/",today,"/0")

df <- fromJSON(link) %>%
  data.frame()

count <- df[1,6]

df <- df %>%
  filter(messages.status == "not.ok")

pages <- floor(count/100)


# Get data
for (cursor in 0:pages) {

  print(paste0("Starting page ",cursor))

  page <- cursor*100

  link <- paste0("https://api.biorxiv.org/details/medrxiv/2019-06-01/",today,"/",
                 page)

  tmp <- fromJSON(link) %>%
    as.data.frame()

  df <- rbind(df, tmp)

}

# Clean data

df$node = seq(1:nrow(df))
names(df) <- gsub("collection.","",names(df))

df <- df %>%
  select(-c(type,server))

df <- df %>%
  select(-starts_with("messages"))

df$link <- paste0("/content/",df$doi,"v",df$version,"?versioned=TRUE")
df$pdf <- paste0("/content/",df$doi,"v",df$version,".full.pdf")
df$category <- stringr::str_to_title(df$category)
df$authors <- stringr::str_to_title(df$authors)
df$author_corresponding <- stringr::str_to_title(df$author_corresponding)


# Save data
write.csv(df,
          "snapshot.csv",
          fileEncoding = "UTF-8",
          row.names = FALSE)

# Push to Github

current_time <- format(Sys.time(), "%Y-%m-%d %H:%M")

writeLines(current_time, "timestamp.txt")

add(repo = getwd(),
    path = "snapshot.csv")

add(repo = getwd(),
    path = "timestamp.txt")

# Commit the file


commit(repo = getwd(),
       message = paste0("Daily snapshot: ", current_time)
)

# Push the repo again
push(object = getwd(),
     credentials = cred_user_pass(username = GITHUB_USER,
                                  password = GITHUB_PASS))

pushover(paste0("Data extraction: Success!\nData upload: Success!"),
         user = PUSHOVER_USER,
         app = PUSHOVER_APP)

