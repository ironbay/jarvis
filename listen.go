package main

import (
	"log"

	"github.com/ironbay/delta/uuid"
	"github.com/ironbay/drs/drs-go"
	"github.com/ironbay/jarvis/event"
	"github.com/ironbay/jarvis/router"
	"github.com/mitchellh/mapstructure"
)

func init() {
	jarvis.server.On("jarvis.listen", func(cmd *drs.Command, conn *drs.Connection, ctx map[string]interface{}) (interface{}, error) {
		args := cmd.Map()
		reg := new(router.Registration)
		mapstructure.Decode(args, reg)
		reg.Key = uuid.Ascending()
		match, _ := conn.Cache.Get("registrations")
		registrations := match.(map[string]*router.Registration)
		registrations[reg.Key] = reg
		if !reg.Once {
			log.Println("Registering Forever", reg.Kind)
			go listen(conn, reg)
			return true, nil
		}
		log.Println("Registering Once", reg.Kind)
		return listen(conn, reg)
	})
}

func listen(conn *drs.Connection, reg *router.Registration) (*event.Event, error) {
	jarvis.router.Add(reg)
	for evt := range reg.Chan {
		if reg.Once {
			return evt, nil
		}
		conn.Fire(&drs.Command{
			Key:    uuid.Ascending(),
			Action: evt.Kind,
			Body:   evt,
		})
	}
	if reg.Once {
		return nil, drs.Error("Cancelled")
	}
	return nil, nil
}
