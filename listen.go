package main

import (
	"github.com/ironbay/delta/uuid"
	"github.com/ironbay/drs/drs-go"
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
			reg.Hook = func(cmd *drs.Command) {
				conn.Fire(cmd)
			}
			return true, nil
		}
		ch := make(chan *drs.Command)
		reg.Hook = func(cmd *drs.Command) {
			ch <- cmd
		}
		result := <-ch
		if result == nil {
			return nil, drs.Error("Cancelled")
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
