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
	server.pipe.On("jarvis.listen", func(cmd *drs.Command, conn *drs.Connection, ctx drs.Dynamic) (interface{}, error) {
		args := cmd.Dynamic()
		reg := new(router.Registration)
		mapstructure.Decode(args, reg)
		reg.Key = uuid.Ascending()
		registrations := conn.Get("registrations").(map[string]*router.Registration)
		registrations[reg.Key] = reg
		if !reg.Once {
			log.Println("Registering for", reg.Kind)
			go listen(conn, reg)
			return true, nil
		}
		log.Println("Once register", reg.Kind)
		return listen(conn, reg)
	})
}

func listen(conn *drs.Connection, reg *router.Registration) (*event.Event, error) {
	server.router.Add(reg)
	for evt := range reg.Chan {
		if reg.Once {
			return evt, nil
		}
		conn.Encode(&drs.Command{
			Key: uuid.Ascending(),
			Action: "jarvis." + evt.Kind,
			Body:   evt,
		})
	}
	if reg.Once {
		return nil, drs.Error("Cancelled")
	}
	return nil, nil
}
