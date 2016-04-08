package client

import (
	"github.com/ironbay/drs/drs-go"
	"github.com/ironbay/drs/drs-go/protocol"
	"github.com/ironbay/drs/drs-go/transports/ws"
	"github.com/ironbay/dynamic"
)

type Client struct {
	connection *drs.Connection
}

type Session struct {
	Data       map[string]interface{}
	Context    map[string]interface{}
	connection *drs.Connection
}

func New(host string) *Client {
	transport := ws.New(dynamic.Empty())
	client := &Client{
		connection: drs.NewConnection(protocol.JSON),
	}
	go client.connection.Dial(transport, host, true)
	return client
}

func (this *Client) On(action string, cb func(*Session)) {
	this.connection.Fire(&drs.Command{
		Action: "jarvis.listen",
		Body: dynamic.Build(
			"action", action,
		),
	})
	this.connection.On(action, func(cmd *drs.Command, conn *drs.Connection, ctx map[string]interface{}) (interface{}, error) {
		body := cmd.Map()
		context := dynamic.Object(body, "context")
		data := dynamic.Object(body, "data")
		cb(&Session{
			Context:    context,
			Data:       data,
			connection: this.connection,
		})
		return true, nil
	})
}

func (this *Client) Regex(action string, pattern string) {
	this.connection.Request(&drs.Command{
		Action: "chat.regex",
		Body: dynamic.Build(
			"data", dynamic.Build(
				"pattern", pattern,
				"action", action,
			),
		),
	})
}

func (this *Session) Response(text string) {
	this.connection.Request(&drs.Command{
		Action: "chat.response",
		Body: dynamic.Build(
			"data", dynamic.Build(
				"text", text,
			),
			"context", this.Context,
		),
	})
}

func (this *Session) Once(action string) (interface{}, error) {
	return this.connection.Request(&drs.Command{
		Action: "jarvis.listen",
		Body: dynamic.Build(
			"action", action,
			"context", this.Context,
			"once", true,
		),
	})
}
