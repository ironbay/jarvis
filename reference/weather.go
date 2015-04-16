package reference

import (
    "github.com/ironbay/snooze"
)

type weatherResult struct {
    Weather []struct {
        Id          int
        Main        string
        Description string
        Icon        string
    }
    Main struct {
        Temp float32
    }
}

type weather struct {
    Get func(location string) (*weatherResult, error) `GET:/data/2.5/weather?q={0}`
}

var Weather = func() *weather {
    w := new(weather)
    client := snooze.Client{Root: "http://api.openweathermap.org"}
    client.Create(w)
    return w
}()
