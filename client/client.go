package client

import (
	"log"

	"github.com/ironbay/drs/drs-go"
	"github.com/ironbay/drs/drs-go/transport/ws"
	"github.com/ironbay/jarvis/event"
	"github.com/ironbay/jarvis/router"
)

type Client struct {
	pipe   *drs.Pipe
	router *router.Router
}

func New() *Client {
	pipe, _ := ws.New(drs.Dynamic{})
	pipe.Router = func(string) (string, error) { return "localhost:12000", nil }
	return &Client{
		pipe:   pipe,
		router: router.New(),
	}
}

func (this *Client) On(kind string, ctx drs.Dynamic, cb func(*event.Event)) {
	log.Println("Sending")
	this.pipe.Send(&drs.Command{
		Action: "jarvis.listen",
		Body: &router.Registration{
			Kind:    kind,
			Context: ctx,
		},
	})
	this.pipe.On("jarvis."+kind, func(cmd *drs.Command, conn *drs.Connection, ctx drs.Dynamic) (interface{}, error) {
		evt := event.From(cmd.Body)
		go cb(evt)
		return true, nil
	})
}

func (this *Client) Once(kind string, ctx drs.Dynamic) *event.Event {
	res, err := this.pipe.Send(&drs.Command{
		Action: "jarvis.listen",
		Body: &router.Registration{
			Kind:    kind,
			Context: ctx,
			Once:    true,
		},
	})
	if err != nil {
		panic(err)
	}
	return event.From(res)
}

func (this *Client) Send(evt *event.Event) {
	this.pipe.Send(&drs.Command{
		Action: "jarvis.event",
		Body:   evt,
	})
}
