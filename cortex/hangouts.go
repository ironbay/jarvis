package cortex

import (
    irc "github.com/fluffle/goirc/client"
    "log"
    "time"
)

type hangouts struct {
    Client *irc.Conn
    buffer chan string
}

type Hangout struct {
    Message string
    From    string
}

var Hangouts = func() *hangouts {

    var r hangouts
    r.buffer = make(chan string)
    timer := time.NewTimer(time.Second)
    go func() {
        <-timer.C
        r.Client.Privmsg("#Jarvis[37b58e0]", <-r.buffer)
    }()

    cfg := irc.NewConfig("jarvis")
    cfg.SSL = false
    cfg.Server = "jarvis.systems:6668"
    cfg.NewNick = func(n string) string { return n + "^" }
    c := irc.Client(cfg)
    r.Client = c

    c.HandleFunc("connected", func(conn *irc.Conn, line *irc.Line) {
        conn.Join("#Jarvis[37b58e0]")
        conn.Join("#Broo[a302fda]")
        Event.Message("Initialized")
    })

    c.HandleFunc(irc.PRIVMSG, func(conn *irc.Conn, line *irc.Line) {
        m := Hangout{line.Text(), line.Nick}
        Event.Emit(&m)
    })

    Event.Listen(func(m *Hangout) {
        if m.From == "JarvisIronbay" {
            return
        }
        Pipe.Handle(r, m.Message, m.From)
    })

    c.HandleFunc("disconnected", func(conn *irc.Conn, line *irc.Line) {
    })

    if err := c.Connect(); err != nil {
        log.Printf("Connection error: %s\n", err)
    }

    Event.Listen(func(m Alert) {
        r.Send(m.Alert())
    })

    return &r
}()

func (h hangouts) Send(msg string) {
    h.buffer <- msg
}
