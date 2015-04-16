package cortex

import (
    irc "github.com/fluffle/goirc/client"
    "regexp"
)

type TorrentUpload struct {
    Id       string
    Name     string
    Url      string
    Category string
    Size     string
}

func init() {
    name := regexp.MustCompile("Name:'([^']+)")
    category := regexp.MustCompile("<([^>]+)")
    id := regexp.MustCompile("torrent/(\\d+)")

    cfg := irc.NewConfig("jarvis")
    cfg.SSL = false
    cfg.Server = "irc.torrentleech.org:7011"
    cfg.NewNick = func(n string) string { return n + "^" }
    c := irc.Client(cfg)

    c.HandleFunc("connected", func(conn *irc.Conn, line *irc.Line) {
        Event.Message("Connected to Torrentleech", NoContext())
        conn.Join("#tlannounces")
    })

    c.HandleFunc(irc.PRIVMSG, func(conn *irc.Conn, line *irc.Line) {
        text := line.Text()
        model := new(TorrentUpload)
        model.Name = name.FindStringSubmatch(text)[1]
        model.Category = category.FindStringSubmatch(text)[1]
        model.Id = id.FindStringSubmatch(text)[1]
        model.Url = "http://www.torrentleech.org/rss/download/" + model.Id + "/" + Torrentleech.Key + "/download"
        Event.Emit(model, NoContext())
    })

    c.HandleFunc("disconnected", func(conn *irc.Conn, line *irc.Line) {
        Event.Error("Reconnecting to Torrentleech...", NoContext())
        c.Connect()
    })

    c.Connect()

}
