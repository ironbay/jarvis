package cortex

import (
    "io"
    "net/http"
    "os"
)

type TorrentStart struct {
    Url  string
    Name string
}

type TorrentFinished struct {
    Name string
    Path string
}

func init() {

    downloaded := "/media/torrents/downloaded/"

    Event.Listen(func(model *TorrentStart, context *Context) {
        path := downloaded + hash(model.Url) + ".torrent"
        out, _ := os.Create(path)
        defer out.Close()
        resp, _ := http.Get(model.Url)
        defer resp.Body.Close()
        io.Copy(out, resp.Body)

        m := ProcessStart{
            Command: "deluge-console add " + path}
        Event.Emit(&m, context)
    })

    Event.Listen(func(model *TorrentFinished, context *Context) {

    })
}
