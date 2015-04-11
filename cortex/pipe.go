package cortex

import (
    "encoding/json"
    "fmt"
    "log"
    "regexp"
)

type Listener interface {
    Send(string)
}

type Context struct {
    Listener
    User string
}

func NoContext() *Context {
    context := new(Context)
    context.User = "daemon"
    return context
}

func (ctx *Context) Listen(exp string) []string {
    cmd := command{
        Regex:   regexp.MustCompile("(?i)" + exp),
        Channel: make(chan []string, 0)}
    arr := Pipe.contextual[ctx.User]
    if arr == nil {
        arr = make([]*command, 0)
    }
    Pipe.contextual[ctx.User] = append(arr, &cmd)
    return <-cmd.Channel
}

type Input struct {
    Text     string
    Listener Listener
    User     string
}

type pipe struct {
    global     []*command
    contextual map[string][]*command
}

type command struct {
    Regex    *regexp.Regexp
    Callback func(*Context, []string)
    Channel  chan []string
}

func (cmd *command) Handle(ctx *Context, input string) bool {
    matches := cmd.Regex.FindStringSubmatch(input)
    if matches == nil {
        return false
    }
    if cmd.Callback != nil {
        go cmd.Callback(ctx, matches)
    }
    if cmd.Channel != nil {
        cmd.Channel <- matches
    }
    return true
}

var Pipe = func() *pipe {
    Event.Listen(func(m fmt.Stringer, context *Context) {
        log.Println(m)
    })

    Event.Listen(func(m Alert, context *Context) {
        log.Println(m.Alert())
    })

    Event.Listen(func(m interface{}, context *Context) {
        json, _ := json.Marshal(m)
        log.Println(string(json))
    })

    r := new(pipe)
    r.global = make([]*command, 0)
    r.contextual = make(map[string][]*command, 0)
    Event.Listen(func(m *Input, context *Context) {
        r.Handle(m.Text, context)
    })

    return r
}()

func (p *pipe) Global(exp string, cb func(*Context, []string)) {
    cmd := command{
        Regex:    regexp.MustCompile("(?i)" + exp),
        Callback: cb}
    p.global = append(p.global, &cmd)
}

func (p *pipe) Handle(input string, context *Context) {
    for _, cmd := range append(p.global) {
        cmd.Handle(context, input)
    }

    contextual := p.contextual[context.User]
    if contextual == nil {
        return
    }
    invalid := make([]*command, 0)
    for _, cmd := range contextual {
        if !cmd.Handle(context, input) {
            invalid = append(invalid, cmd)
        }
    }
    p.contextual[context.User] = invalid
}
