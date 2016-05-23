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

func New(host string, dc func(err error)) (*Client, error) {
	transport := ws.New(dynamic.Empty())
	client := &Client{
		connection: drs.NewConnection(),
	}
	client.connection.OnDisconnect = dc
	if err := client.connection.Dial(protocol.JSON, transport, host); err != nil {
		return nil, err
	}
	return client, nil
}

func (this *Client) On(action string, ctx map[string]interface{}, cb func(*Session)) {
	this.connection.Request(&drs.Command{
		Action: "jarvis.listen",
		Body: dynamic.Build(
			"action", action,
			"context", ctx,
		),
	})
	this.connection.On(action, func(msg *drs.Message) (interface{}, error) {
		body := msg.Command.Map()
		context := dynamic.Object(body, "context")
		data := dynamic.Object(body, "data")
		cb(&Session{
			Context:    context,
			Data:       data,
			connection: msg.Connection,
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

func (this *Client) Once(action string, ctx map[string]interface{}) (interface{}, error) {
	return this.connection.Request(&drs.Command{
		Action: "jarvis.listen",
		Body: dynamic.Build(
			"action", action,
			"context", ctx,
			"once", true,
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

func (this *Session) Emit(action string, data interface{}) {
	this.connection.Request(&drs.Command{
		Action: action,
		Body: dynamic.Build(
			"data", data,
			"context", this.Context,
		),
	})
}

func (this *Client) Emit(action string, data interface{}, context map[string]interface{}) {
	this.connection.Request(&drs.Command{
		Action: action,
		Body: dynamic.Build(
			"data", data,
			"context", context,
		),
	})
}

func (this *Client) Close() {
	this.connection.Close()
}
