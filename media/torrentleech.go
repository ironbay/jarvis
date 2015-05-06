package media

import (
    "fmt"
    "github.com/PuerkitoBio/goquery"
    "github.com/ironbay/jarvis/cortex"
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

    cortex.Pipe.Global("download (.+)", func(ctx *cortex.Context, args []string) {
        matches := m.Search(args[1])
        if len(matches) == 0 {
            ctx.Send("No matches found")
            return
        }
        if len(matches) > 0 {
            ctx.Send("Which one?")
            for i := 0; i < 3; i++ {
                if i >= len(matches) {
                    break
                }
                ctx.Send(fmt.Sprintf("%v. %v", i, matches[i].Name))
            }
            args = ctx.Listen("^(\\d)$")
            index, _ := strconv.Atoi(args[1])
            if index >= len(matches) {
                ctx.Send("Invalid choice")
                return
            }
            m := new(TorrentStart)
            m.Url = matches[index].Url
            cortex.Event.Emit(m, ctx)
            ctx.Send("Downloading " + matches[index].Name)
            return
        }
        m := new(TorrentStart)
        m.Url = matches[0].Url
        cortex.Event.Emit(m, ctx)
        ctx.Send("Downloading " + matches[0].Name)
    })

    return &m
}()

func (t *torrentleech) raw(url string) []*TorrentUpload {
    client := http.Client{}
    req, _ := http.NewRequest("GET", url, nil)
    req.Header.Add("Cookie", "member_id=53563; tluid=522483; tlpass=05c548a8a0eee54685374e912c28f518a2926b22; pass_hash=ef5be2fa3121fe9947bbbf247bddbc99; session_id=a8a4a2538b8a70a3ade7420cfeb0bfc9;")
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
