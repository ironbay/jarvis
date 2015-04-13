package media

import (
    "github.com/ironbay/jarvis/cortex"
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
    cortex.Event.Listen(func(model *TorrentUpload, context *cortex.Context) {
        if model.Category != "TV :: Episodes" {
            return
        }
        shows := make([]Show, 0)
        cortex.Database.Get(&shows)
        lower := strings.ToLower(model.Name)
        for _, m := range shows {
            if strings.Index(lower, strings.ToLower(m.Name)) == 0 {
                m := TorrentStart{
                    Url:  model.Url,
                    Name: model.Name}
                cortex.Event.Emit(&m, context)
                return
            }
        }
    })

    cortex.Event.Listen(func(model *Imdb, context *cortex.Context) {
        if model.Type != "TV" {
            return
        }
        r := Show{Name: model.Name}
        cortex.Event.Emit(&r, context)
    })

    cortex.Pipe.Global("follow show (.+)", func(context *cortex.Context, args []string) {
        r, _ := reference.Omdb.Search(args[1], "series")
        if r["Response"].(string) != "True" {
            return
        }
        m := Show{r["Title"].(string)}
        cortex.Event.Emit(&m, context)
    })

}
