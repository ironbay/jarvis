package cortex

import (
    "github.com/ironbay/jarvis/cortex/reference"
    "strings"
)

type Show struct {
    Name string
}

func (s *Show) Key() string {
    return s.Name
}

func (s *Show) Alert() string {
    return "Now following show: " + s.Name
}

func init() {
    Event.Listen(func(model *TorrentUpload, context *Context) {
        if model.Category != "TV :: Episodes" {
            return
        }
        shows := make([]Show, 0)
        Database.Get(&shows)
        lower := strings.ToLower(model.Name)
        for _, m := range shows {
            if strings.Index(lower, strings.ToLower(m.Name)) == 0 {
                m := TorrentStart{
                    Url:  model.Url,
                    Name: model.Name}
                Event.Emit(&m, context)
                return
            }
        }
    })

    Event.Listen(func(model *Imdb, context *Context) {
        if model.Type != "TV" {
            return
        }
        r := Show{Name: model.Name}
        Event.Emit(&r, context)
    })

    Pipe.Global("follow show (.+)", func(context *Context, args []string) {
        r, _ := reference.Omdb.Search(args[1], "series")
        if r["Response"].(string) != "True" {
            return
        }
        m := Show{r["Title"].(string)}
        Event.Emit(&m, context)
    })

}
