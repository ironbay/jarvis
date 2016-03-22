package main

import (
	"encoding/json"
	"log"

	"github.com/ironbay/drs/drs-go"
	"github.com/ironbay/dynamic"
	"github.com/ironbay/jarvis/event"
)

func init() {
	server.pipe.On("jarvis.event", func(cmd *drs.Command, conn *drs.Connection, ctx map[string]interface{}) (interface{}, error) {
		data, _ := json.MarshalIndent(cmd.Body, "", "  ")
		log.Println(string(data))
		evt := event.From(cmd.Body)
		if evt == nil {
			return nil, nil
		}
		if evt.Context == nil {
			evt.Context = dynamic.Empty()
		}
		if evt.Data == nil {
			evt.Data = dynamic.Empty()
		}
		if evt.Context == nil {
			evt.Context = dynamic.Empty()
		}
		server.router.Emit(evt)
		return true, nil
	})
}
