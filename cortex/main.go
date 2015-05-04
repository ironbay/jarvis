package cortex

import (
    "crypto/md5"
    "encoding/hex"
    "log"
    "os"
)

func Run() {
    log.Println("Initialized")
    Pipe.Global("^jarvis", func(c *Context, matches []string) {
        c.Send("Hello " + c.User)
        c.Listen("how are you")
        c.Send("I'm doing fantastic " + c.User)
    })

    Pipe.Global("where are you", func(c *Context, matches []string) {

        host, _ := os.Hostname()
        c.Send("I am at " + host)

    })

}

func Hash(text string) string {
    hasher := md5.New()
    hasher.Write([]byte(text))
    return hex.EncodeToString(hasher.Sum(nil))
}
