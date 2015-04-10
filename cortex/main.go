package cortex

import (
    "crypto/md5"
    "encoding/hex"
    "log"
)

func Run() {
    d := make([]Show, 0)
    Database.Get(&d)
    log.Println("Initialized")

    Pipe.Global("^jarvis", func(c *Context, matches []string) {
        c.Send("Hello " + c.User)
        c.Listen("how are you", func(c *Context, matches []string) {
            c.Send("I'm doing great " + c.User)
        })
    })

}

func hash(text string) string {
    hasher := md5.New()
    hasher.Write([]byte(text))
    return hex.EncodeToString(hasher.Sum(nil))
}
