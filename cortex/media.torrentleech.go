package cortex

import (
    "fmt"
    "github.com/PuerkitoBio/goquery"
    "log"
    "net/http"
    "strconv"
)

type torrentleech struct {
    Key string
}

type torrentleechEntry struct {
    Name string
}

var Torrentleech = func() *torrentleech {
    m := torrentleech{
        Key: "c7afa073572a4ee09f8c"}

    Pipe.Global("download (.+)", func(l *Context, args []string) {
        matches := m.Search(args[1])
        if len(matches) == 0 {
            l.Send("No matches found")
            return
        }
        if len(matches) > 0 {
            l.Send("Which one?")
            for i := 0; i < 3; i++ {
                if i >= len(matches) {
                    break
                }
                l.Send(fmt.Sprintf("%v. %v", i, matches[i].Name))
            }
            l.Listen("^(\\d)$", func(ctx *Context, args []string) {
                index, _ := strconv.Atoi(args[1])
                if index >= len(matches) {
                    l.Send("Invalid choice")
                    return
                }
                m := new(TorrentStart)
                m.Url = matches[index].Url
                Event.Emit(m)
                l.Send("Downloading " + matches[index].Name)
            })
            return
        }
        m := new(TorrentStart)
        m.Url = matches[0].Url
        Event.Emit(m)
        l.Send("Downloading " + matches[0].Name)
    })

    return &m
}()

func (t *torrentleech) raw(url string) []*TorrentUpload {
    client := http.Client{}
    req, _ := http.NewRequest("GET", url, nil)
    req.Header.Add("Cookie", "member_id=53563; tluid=522483; tlpass=37fa4364bc5e903f4e5664caf3820e988f41e4e3; pass_hash=ef5be2fa3121fe9947bbbf247bddbc99; session_id=a8a4a2538b8a70a3ade7420cfeb0bfc9;")
    res, _ := client.Do(req)
    doc, _ := goquery.NewDocumentFromResponse(res)

    matches := make([]*TorrentUpload, 0)
    doc.Find("#torrents tr").Each(func(i int, row *goquery.Selection) {
        if i > 9 {
            return
        }
        id, exists := row.Attr("id")
        if !exists {
            return
        }

        m := new(TorrentUpload)
        m.Name = row.Find(".title").Text()
        m.Url = "http://www.torrentleech.org/rss/download/" + id + "/" + t.Key + "/download"
        m.Size = row.Find("td:nth-child(5)").Text()
        log.Println(m)
        matches = append(matches, m)
    })
    return matches

}

func (t *torrentleech) Search(query string) []*TorrentUpload {
    return t.raw("http://www.torrentleech.org/torrents/browse/index/query/" + query + "/categories/10%2C11%2C13%2C14%2C2%2C26%2C27/orderby/seeders/order/desc")

}
