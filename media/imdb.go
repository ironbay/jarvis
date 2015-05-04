package media

import (
    "github.com/PuerkitoBio/goquery"
    "github.com/ironbay/jarvis/cortex"
    "strings"
)

type Imdb struct {
    Name string
    Type string
}

func init() {
    cortex.Event.Listen(func(m *cortex.Browse, context *cortex.Context) {
        if !strings.Contains(m.Url, "imdb.com") {
            return
        }

        doc, _ := goquery.NewDocument(m.Url)
        r := new(Imdb)
        r.Name, _ = doc.Find("meta[property='og:title']").First().Attr("content")
        r.Type = "Movie"
        if strings.Contains(r.Name, "TV Series") {
            r.Type = "TV"
        }
        r.Name = doc.Find("span[itemprop='name']").First().Text()
        if r.Name == "" {
            return
        }
        cortex.Event.Emit(r, context)

    })
}
