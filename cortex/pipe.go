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

func (ctx *Context) Listen(exp string, cb func(*Context, []string)) {
    cmd := command{
        Regex:    regexp.MustCompile("(?i)" + exp),
        Callback: cb}
    arr := Pipe.contextual[ctx.User]
    if arr == nil {
        arr = make([]*command, 0)
    }
    Pipe.contextual[ctx.User] = append(arr, &cmd)
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
}

func (cmd *command) Handle(ctx *Context, input string) bool {
    matches := cmd.Regex.FindStringSubmatch(input)
    if matches == nil {
        return false
    }
    go cmd.Callback(ctx, matches)
    return true
}

var Pipe = func() *pipe {
    Event.Listen(func(m fmt.Stringer) {
        log.Println(m)
    })

    Event.Listen(func(m Alert) {
        log.Println(m.Alert())
    })

    Event.Listen(func(m interface{}) {
        json, _ := json.Marshal(m)
        log.Println(string(json))
    })

    r := new(pipe)
    r.global = make([]*command, 0)
    r.contextual = make(map[string][]*command, 0)
    Event.Listen(func(m *Input) {
        r.Handle(m.Listener, m.Text, m.User)
    })

    return r
}()

func (p *pipe) Global(exp string, cb func(*Context, []string)) {
    cmd := command{
        Regex:    regexp.MustCompile("(?i)" + exp),
        Callback: cb}
    p.global = append(p.global, &cmd)
}

func (p *pipe) Handle(listener Listener, input string, user string) {
    context := new(Context)
    context.Listener = listener
    context.User = user
    for _, cmd := range append(p.global) {
        cmd.Handle(context, input)
    }

    contextual := p.contextual[user]
    if contextual == nil {
        return
    }
    invalid := make([]*command, 0)
    for _, cmd := range contextual {
        if !cmd.Handle(context, input) {
            invalid = append(invalid, cmd)
        }
    }
    p.contextual[user] = invalid
}
