server = shinyServer(function(input, output, session) {

    values = reactiveValues(
        songs_df = data.frame(
            urls = character(),
            title = character()
        )
    )

    observeEvent(input$url_space,{

        if (input$url_space != '' & !is.na(input$url_space)) {
            if(input$url_space %in% as.character(values$songs_df[,'urls'])) {
                shinyalert('Oops','Song already in list','error')
            } else {

                songs_new = get_title_by_url(input$url_space)

                if (length(songs_new)) {
                    values$songs_df = rbind(
                        values$songs_df,
                        songs_new
                    )

                    DT = values$songs_df
                    render_songs_dt(DT)

                }
            }
            updateTextAreaInput(session,inputId='url_space',label = 'Place link here' ,value='')
        }

    },ignoreInit = TRUE)

    observeEvent(input$DeleteButtonClickedEvent,{
        deletion_row = as.numeric(gsub('delete_','',input$DeleteButtonClicked))
        values$songs_df = values$songs_df[-deletion_row,]
        DT = values$songs_df
        render_songs_dt(DT)
    })

    observeEvent(input$Download,{
        shinyalert(title = 'Download Songs', text = 'Enter Folder Name', type = 'input',callbackR = function(value) {downloadSongs(value)})
    })

    render_songs_dt = function(DT) {

        if (nrow(DT)) {
            output$songs_df = DT::renderDataTable({
                DT[["deleteButtons"]]=paste0('
                    <div class="btn-group" role="group" aria-label="Basic example">
                        <button type="button" class="btn btn-secondary delete" id=delete_',as.character(1:nrow(DT)),'
                            onclick = "
                                Shiny.onInputChange(\'DeleteButtonClicked\',this.id);
                                Shiny.onInputChange(\'DeleteButtonClickedEvent\',String(window.performance.now()));">
                            <img src = "delete_icon.png"  height = 20px; style="text-align:center;padding: 0;" >
                        </button>
                    </div>'
                )


                DT = DT[,c('deleteButtons','urls','titles')]
                colnames(DT) = c(' ','urls',' Title')

                datatable(
                    DT,
                    class="compact cell-border",
                    rownames=FALSE,
                    editable = TRUE,
                    selection = 'none',
                    escape = FALSE,
                    options = list(
                        paging = FALSE,
                        dom = 't',
                        paging = FALSE,
                        scrollY = 760,
                        columnDefs = list(
                            list(
                                visible=FALSE,
                                targets=1
                            )
                        )
                    )
                )
            })
        } else {
            output$songs_df = NULL
        }
     }

    downloadSongs = function(value) {

        path = paste0(as.character(Sys.getenv()["HOME"]),'/Music/')
        files = list.files(path = path)

        if (value %in% files) {
            shinyalert('Oops',paste('Folder',value,'already exists!','error'))
        } else {

            if (nrow(values$songs_df)) {
                dir.create(paste0(path,value))

                setwd(paste0(path,'/',value))

                counter = 1

                for (counter in  seq(nrow(values$songs_df))) {

                    system_cmd = paste0(
                        'youtube-dl --extract-audio --audio-format mp3 --output "',
                        values$songs_df[counter,'titles'],
                        '.%(ext)s" ',
                        values$songs_df[counter,'urls']
                    )
                    message(system_cmd)
                    system(system_cmd)
                    print(paste('Song', counter,'out of',nrow(values$songs_df),'downloaded'))
                }
            }
             else {
                 shinyalert('Oops','No songs selected!','error')
            }
        }
    }
})