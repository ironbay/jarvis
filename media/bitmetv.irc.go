package media

/*
import (
    irc "github.com/fluffle/goirc/client"
    "log"
    "regexp"
    "strings"
    "time"
)

func init() {
    rgx := regexp.MustCompile("BitMeTV\\.ORG Torrents: \\[ (.*?) \\] Size: \\[ (.*?) \\] Link: \\[.*?id=(.*?)&hit=1 \\]")

    cfg := irc.NewConfig("_dax")
    cfg.SSL = false
    cfg.Server = "irc.bitmetv.org"
    cfg.NewNick = func(n string) string { return n + "^" }
    c := irc.Client(cfg)

    c.HandleFunc("connected", func(conn *irc.Conn, line *irc.Line) {
        go func() {
            time.Sleep(time.Second * 2)
            conn.Privmsg("NickServ", "IDENTIFY thisispassword")
        }()
    })
    c.HandleFunc("NOTICE", func(conn *irc.Conn, line *irc.Line) {
        if strings.Contains(line.Text(), "Password accepted") {
            c.Privmsg("BitMeTV", "!invite _dax 7b04cd712bc2")
        }
    })
    c.HandleFunc(irc.PRIVMSG, func(conn *irc.Conn, line *irc.Line) {
        text := line.Text()
        log.Println(line.Text())
        return
        model := new(TorrentUpload)
        matches := rgx.FindStringSubmatch(text)
        model.Name = matches[1]
        model.Url = "http://www.torrentleech.org/rss/download/" + id.FindStringSubmatch(text)[1] + "/" + Torrentleech.Key + "/download"
        Event.Emit(model, NoContext())
    })

    c.HandleFunc("disconnected", func(conn *irc.Conn, line *irc.Line) {
        Event.Error("Reconnecting to Torrentleech...", NoContext())
    })

    c.HandleFunc(irc.INVITE, func(conn *irc.Conn, line *irc.Line) {
        if line.Text() != "#bitmetv.announce" {
            return
        }
        log.Println(line.Text())
        conn.Join("#bitmetv.announce")
        log.Println("Joining announce")
        Event.Message("Connected to BitMeTV", NoContext())

    })

    if err := c.Connect(); err != nil {
        log.Printf("Connection error: %s\n", err)
    }

}

*/
