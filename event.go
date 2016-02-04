package main

import (
	"github.com/ironbay/drs/drs-go"
	"github.com/ironbay/jarvis/event"
)

func init() {
	server.pipe.On("jarvis.event", func(cmd *drs.Command, conn *drs.Connection, ctx drs.Dynamic) (interface{}, error) {
		evt := event.From(cmd.Body)
		if evt == nil {
			return nil, nil
		}
		server.router.Process(evt)
		return true, nil
	})
}
