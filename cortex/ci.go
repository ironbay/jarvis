package cortex

import (
    "os"
)

type Github struct {
}

func (*Github) Alert() string {
    return "Commit to master, rebuilding..."
}

func init() {
    Event.Listen(func(model *Github, ctx *Context) {
        os.Exit(0)
    })
}
