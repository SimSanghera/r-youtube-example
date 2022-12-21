#----- YouTube Comment Scraper -----

#-----------------------------------#
# Creating an example code to access YouTube's API and extract comments 
# and the number of likes from several videos and store in a tidy 
# dataframe.

# A youtube API Call has the following format:
#   https://www.googleapis.com/youtube/v3/{resource}?{parameters}
#   resource = what kind of info to extract
#   parameters = to further customise results, multiple params separated by &
#

#----- Load Libraries -----
packs <- c("tidyverse",
           "jsonlite",
           "here",
           "httr",
           "tuber",
           "lubridate",
           "stringi",
           "wordcloud",
           "gridExtra",
           "purrr")

lapply(packs,
       library,
       character.only = TRUE)

#----- API Access Keys  -----
api_key   <- "AIzaSyC4Uo_UFVB5frVtLt17bCa-shYJv16W7HU"
clientid  <- "564104900826-79fd56roni4p735ap9jm66qvuhu8blk9.apps.googleusercontent.com"
clientsec <- "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"

# Authenticate the app using tuber's yt_oauth() function
yt_oauth(app_id     = clientid,
         app_secret = clientsec,
         token      = "")


#----- Playlist Data  -----
# Extract example data from GCN's epic ride playlist
# https://www.youtube.com/watch?v=TdSGmKSlcS8&list=PLUdAMlZtaV13Kk9-QvHb71mGl6QvkCMCJ
# 
# playlistId parameter specifies ID of the playlist
# extract playlistId from the url string


epic_rides_id <- stringr::str_split(
  "https://www.youtube.com/watch?v=TdSGmKSlcS8&list=PLUdAMlZtaV13Kk9-QvHb71mGl6QvkCMCJ",
  pattern = "=",
  n = 3,
  simplify = TRUE)

epic_rides_id


# obtain videos from playlist
epic_ride_videos <- tuber::get_playlist_items(
  filter = c(playlist_id = epic_rides_id[, 3]),
  part = "contentDetails",
)

# quick check of data
epic_ride_videos %>% dplyr::glimpse()



#----- Extract Data from Videos -----
# collect all the video IDs
# then use tuber::get_stats() function to pull all the stats from the videos

epic_ride_video_ids <- as.vector(epic_ride_videos$contentDetails.videoId)

dplyr::glimpse(epic_ride_video_ids)

get_video_stats <- function(id) {
  # this is just a basic function where we pass the video id as the only 
  #   parameter
  tuber::get_stats(video_id = id)
}


# Apply the function across all videos using the list of video IDs extracted
#   above
epic_rides_all_stats <- purrr::map_df(
  .x = epic_ride_video_ids,
  .f = get_video_stats
)

# Quick check
dplyr::glimpse(epic_rides_all_stats)


#----- Extract Comments -----
# Firstly, create a function to extract comments from videos
# Then apply the function across all videos, using the list of video IDs

get_vid_comments <- function(id) {
  tuber::get_all_comments(
    video_id = id
  )
}

epic_rides_all_comments <- purrr::map_df(
  .x = epic_ride_video_ids,
  .f = get_vid_comments
)

dplyr::glimpse(epic_rides_all_comments)

#----- Export data  -----
readr::write_csv(
  x = as.data.frame(epic_rides_all_stats),
  file = paste0("data/",
                base::noquote(lubridate::today()),
                "-epic_rides_all_stats.csv")
)

# Also export the video ids
readr::write_csv(
  x = as.data.frame(epic_ride_videos),
  file = paste0("data/",
                base::noquote(lubridate::today()),
                "-epic_rides_videos.csv")
)

readr::write_csv(
  x = as.data.frame(epic_rides_all_comments),
  file = paste0("data/",
                base::noquote(lubridate::today()),
                "-epic_rides_all_comments.csv")
)
