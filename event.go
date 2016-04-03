package main

import (
	"encoding/json"
	"log"

	"github.com/ironbay/drs/drs-go"
	"github.com/ironbay/jarvis/event"
)

func init() {
	jarvis.server.On("jarvis.event", func(cmd *drs.Command, conn *drs.Connection, ctx map[string]interface{}) (interface{}, error) {
		data, _ := json.MarshalIndent(cmd.Body, "", "  ")
		log.Println(string(data))
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
		jarvis.router.Emit(evt)
		return true, nil
	})
}
