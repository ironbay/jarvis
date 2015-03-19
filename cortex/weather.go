package cortex

import (
    "github.com/ironbay/jarvis/cortex/reference"
)

func init() {
    Pipe.Listen("weather", func(l Listener, args []string) {
        r, _ := reference.Weather.Get("Manhattan")
        l.Send(r["weather"].(map[string]interface{})["main"].(string))
    })
}
