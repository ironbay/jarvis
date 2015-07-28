package reference

import (
    "github.com/ironbay/snooze"
)

type omdb struct {
    Search func(title string, kind string) (map[string]interface{}, error) `method:"GET" path:"/?t={0}&type={1}"`
}

var Omdb = func() *omdb {
    o := new(omdb)
    client := snooze.Client{Root: "http://www.omdbapi.com"}
    client.Create(o)
    return o
}()
