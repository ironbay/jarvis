package cortex

import ()

type Browse struct {
    Url      string
    Referrer string
}

func init() {
    Event.Listen(func(model *Browse, context *Context) {
    })
}
