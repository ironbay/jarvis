package client

import (
	"encoding/json"
	"log"
	"net/http"

	"golang.org/x/net/websocket"

	"github.com/ironbay/jarvis/cortex"
	"github.com/ironbay/snooze"
)

type Client struct {
	Root      string
	Context   string
	EmitModel func(cortex.Event) error           `method:"POST" path:"/emit/model"`
	Once      func(string) (cortex.Event, error) `method:"GET" path:"/subscribe/once?pattern={0}"`
}

func NewClient(base string, contextType string) *Client {
	client := snooze.Client{
		Root: "http://" + base,
		Before: func(r *http.Request, c *http.Client) {
			c.Timeout = 0
		},
	}
	result := new(Client)
	result.Root = base
	result.Context = contextType
	client.Create(result)
	return result
}

func (this *Client) Forever(pattern string) (chan *cortex.Event, error) {
	ws, err := websocket.Dial("ws://"+this.Root+"/subscribe/forever?pattern="+pattern, "", "http://jarvis")
	if err != nil {
		log.Println(err)
		return nil, err
	}
	result := make(chan *cortex.Event)

	go func() {
		msg := make([]byte, 4096)
		for {
			n, err := ws.Read(msg)
			if err != nil {
				break
			}
			event := new(cortex.Event)
			err = json.Unmarshal(msg[:n], &event)
			result <- event
		}
		close(result)
	}()

	return result, nil
}

func (this *Client) RegisterRegex(modelType string, regex string) {
	this.EmitModel(cortex.Event{
		Type:    "register.regex",
		Context: cortex.Context{"type": this.Context},
		Model:   cortex.Model{"type": modelType, "regex": regex},
	})
}

func (this *Client) RegisterStringable(modelType string, regex string) {
	this.EmitModel(cortex.Event{
		Type:    "register.stringable",
		Context: this.GetContext(),
		Model:   cortex.Model{"type": modelType, "template": regex},
	})
}

func (this *Client) GetContext() cortex.Context {
	return cortex.Context{"type": this.Context}
}
