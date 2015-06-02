package media

import (
    "github.com/ironbay/jarvis/cortex"
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

    cortex.Event.Listen(func(model *TorrentStart, context *cortex.Context) {
        path := downloaded + cortex.Hash(model.Url) + ".torrent"
        out, _ := os.Create(path)
        defer out.Close()
        resp, _ := http.Get(model.Url)
        defer resp.Body.Close()
        io.Copy(out, resp.Body)
    })

    cortex.Event.Listen(func(model *TorrentFinished, context *cortex.Context) {

    })
}
