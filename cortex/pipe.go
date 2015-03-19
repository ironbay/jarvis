package cortex

import (
    "encoding/json"
    "fmt"
    "log"
    "regexp"
)

type Alert interface {
    Alert() string
}

type Listener interface {
    Send(string)
}

type Input struct {
    Text     string
    Listener Listener
}

type pipe struct {
    Global []*command
    Once   []*command
}

type command struct {
    Regex    *regexp.Regexp
    Callback func(Listener, []string)
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
    r.Global = make([]*command, 0)
    r.Once = make([]*command, 0)
    Event.Listen(func(m *Input) {
        r.Handle(m.Listener, m.Text)
    })

    return r
}()

func (p *pipe) Listen(exp string, cb func(Listener, []string)) {
    cmd := command{
        Regex:    regexp.MustCompile("(?i)" + exp),
        Callback: cb}
    p.Global = append(p.Global, &cmd)
}

func (p *pipe) Next(exp string, cb func(Listener, []string)) {
    cmd := command{
        Regex:    regexp.MustCompile("(?i)" + exp),
        Callback: cb}
    p.Once = append(p.Once, &cmd)
}

func (p *pipe) Handle(listener Listener, input string) {
    for _, cmd := range append(p.Global, p.Once...) {
        matches := cmd.Regex.FindStringSubmatch(input)
        if matches == nil {
            continue
        }
        go cmd.Callback(listener, matches)
    }
    p.Once = make([]*command, 0)
}
