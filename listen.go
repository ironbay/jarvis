package main

import (
	"github.com/ironbay/delta/uuid"
	"github.com/ironbay/drs/drs-go"
	"github.com/ironbay/go-util/actor"
	"github.com/ironbay/go-util/console"
	"github.com/ironbay/jarvis/router"
	"github.com/mitchellh/mapstructure"
)

func init() {
	jarvis.server.On("jarvis.listen", func(msg *drs.Message) (interface{}, error) {
		console.JSON(msg.Command)
		args := msg.Command.Map()
		reg := new(router.Registration)
		mapstructure.Decode(args, reg)
		reg.Key = uuid.Ascending()
		match, _ := msg.Connection.Cache.Get("registrations")
		registrations := match.(map[string]*router.Registration)
		registrations[reg.Key] = reg
		jarvis.router.Add(reg)
		if !reg.Once {
			reg.Hook = func(cmd *drs.Command) {
				msg.Connection.Fire(cmd)
			}
			return true, nil
		}
		ch := make(chan *drs.Command)
		reg.Hook = func(cmd *drs.Command) {
			ch <- cmd
		}
		result := <-ch
		if result == nil {
			return nil, actor.Error("Cancelled")
		}
		return result, nil
	})
}

/*
func listen(conn *drs.Connection, reg *router.Registration) (interface{}, error) {
	jarvis.router.Add(reg)
	defer jarvis.router.Remove(reg.Key)
	for cmd := range reg.Chan {
		if reg.Once {
			return cmd.Body, nil
		}
		conn.Fire(cmd)
	}
	if reg.Once {
		return nil, drs.Error("Cancelled")
	}
	return nil, nil
}

*/
