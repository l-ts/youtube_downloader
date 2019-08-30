library(xml2)
library(rvest)


trim <- function (x) gsub("^\\s+|\\s+$", "", x)


get_title_by_url = function(url) {

    new_url_added_try_catch = tryCatch({
        webpage = read_html(url)
        result = TRUE
        result
    }, warning = function(w) {
        result = FALSE
        result
    }, error = function(e) {
        result = FALSE
        result
    }
    )



    if (new_url_added_try_catch) {

        # check if it is playlist
        playlist_ind = rvest::html_nodes(webpage,'.playlist-video ')
        if (length(playlist_ind)) {

            urls = playlist_ind %>%
                xml_attr('href')

            urls = paste0('https://www.youtube.com',urls)
            titles = rvest::html_nodes(webpage,'h4') %>% html_text()

            # get as many titles as urls
            # (there are some dummy metadata retrieved as titles)
            # e.g. title , artist, album, etc...
            titles = titles[seq(length(urls))]
            titles = trim(titles)

            songs_df = data.frame(cbind(urls,titles))
            return(songs_df)

        } else {
            urls = url
            titles = rvest::html_nodes(webpage,'.watch-title-container') %>% html_text()
            titles = trim(titles)

            songs_df = data.frame(cbind(urls,titles))
            return(songs_df)

        }
    } else {
        return(character(0))
    }
}