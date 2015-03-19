package cortex

import (
    "crypto/md5"
    "encoding/hex"
    "log"
)

func Run() {
    d := make([]Show, 0)
    Database.Get(&d)

    Pipe.Listen("(bitch|fa..ot)", func(l Listener, args []string) {
        l.Send("You the " + args[1])
    })

    Pipe.Listen("zeeshan", func(l Listener, args []string) {
        l.Send("Zeeshan? Isn't he always wrong")
    })

    Pipe.Listen("jarvis$", func(l Listener, args []string) {
        l.Send("What up")
    })

    Pipe.Listen("anime", func(l Listener, args []string) {
        l.Send("Anime sucks")
    })

    Pipe.Listen("halo", func(l Listener, args []string) {
        l.Send("You suck at halo")
    })

    Pipe.Listen("lmao", func(l Listener, args []string) {
        l.Send("Hahaha")
    })

    log.Println("Initialized")

}

func hash(text string) string {
    hasher := md5.New()
    hasher.Write([]byte(text))
    return hex.EncodeToString(hasher.Sum(nil))
}
