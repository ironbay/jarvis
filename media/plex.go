package media

import (
    "github.com/ironbay/snooze"
    "net/http"
)

type plexSession struct {
    Refresh func(id int) (map[string]interface{}, error) `method:"GET" path:"/library/sections/{0}/refresh"`
}

var Plex = func() *plexSession {
    client := snooze.Client{
        Root: "http://ironbay.digital:32400",
        Before: func(r *http.Request, c *http.Client) {
            values := r.URL.Query()
            values.Add("X-Plex-Token", "TMpiwqiqL2q41RxqgU8r")
            r.URL.RawQuery = values.Encode()
        }}
    result := new(plexSession)
    client.Create(result)
    return result

}()
