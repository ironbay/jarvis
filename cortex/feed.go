package cortex

import ()

type feed struct {
    sources []string
}

var Feed = func() *feed {
    return new(feed)
}()
