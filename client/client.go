package client

import (
	"encoding/json"
	"net/http"

	"golang.org/x/net/websocket"

	"github.com/ironbay/jarvis/cortex"
	"github.com/ironbay/snooze"
)

type Client struct {
	Root               string
	EmitModel          func(cortex.Event) error           `method:"POST" path:"/emit/model"`
	RegisterRegex      func(cortex.RegexModel)            `method:"POST" path:"/register/regex"`
	RegisterStringable func(cortex.RegexModel)            `method:"POST" path:"/register/stringable"`
	Once               func(string) (cortex.Event, error) `method:"GET" path:"/subscribe/once?pattern={0}"`
}

func NewClient(base string) *Client {
	client := snooze.Client{
		Root: base,
		Before: func(r *http.Request, c *http.Client) {
			c.Timeout = 0
		},
	}
	result := new(Client)
	result.Root = base
	client.Create(result)
	return result
}

func (this *Client) Forever(pattern string) (chan *cortex.Event, error) {
	ws, err := websocket.Dial(this.Root+"/subscribe/forever?pattern="+pattern, "", "")
	if err != nil {
		return nil, err
	}
	result := make(chan *cortex.Event)

	go func() {
		msg := make([]byte, 4096)
		for {
			_, err := ws.Read(msg)
			if err != nil {
				break
			}
			event := new(cortex.Event)
			json.Unmarshal(msg, &event)
		}
		close(result)
	}()

	return result, nil

}
