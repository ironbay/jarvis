package main

import (
	"encoding/json"
	"log"

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
			evt.Context = make(drs.Dynamic)
		}
		data, _ := json.MarshalIndent(evt, "", "  ")
		log.Println(string(data))
		server.router.Emit(evt)
		return true, nil
	})
}
