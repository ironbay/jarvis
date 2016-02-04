package main

import (
	"log"

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
		log.Print(reg)
		if !reg.Once {
			go listen(conn, reg)
			return true, nil
		}
		return listen(conn, reg), nil
	})
}

func listen(conn *drs.Connection, reg *router.Registration) *event.Event {
	server.router.Add(reg)
	for evt := range reg.Chan {
		conn.Encode(&drs.Command{
			Action: "jarvis.event",
			Body:   evt,
		})
	}
	return nil
}
