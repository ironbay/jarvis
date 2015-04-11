package cortex

type Alert interface {
    Alert() string
}
type Error struct {
    Message string
}

func (e *Error) Alert() string {
    return "Error: " + e.Message
}

type Message struct {
    Message string
}

func (e *Message) Alert() string {
    return e.Message
}

func init() {
    Event.Listen(func(m *Message, context *Context) {

    })

    Event.Listen(func(e *Error, context *Context) {

    })
}
