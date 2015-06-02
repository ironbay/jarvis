package cortex

import (
    "os"
    "time"
)

type Github struct {
}

func (*Github) Alert() string {
    return "Commit to master, rebuilding..."
}

func init() {
    Event.Listen(func(model *Github, ctx *Context) {
        time.Sleep(time.Second * 5)
        os.Exit(0)
    })
}
