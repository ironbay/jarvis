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
		if evt.Context == nil {
			evt.Context = make(drs.Dynamic)
		}
		if evt.Data == nil {
			evt.Data = make(drs.Dynamic)
		}
		if evt.Context == nil {

		}
		server.router.Emit(evt)
		return true, nil
	})
}
