package main

import "github.com/ironbay/drs/drs-go"

func init() {
	jarvis.server.On("*", func(cmd *drs.Command, conn *drs.Connection, ctx map[string]interface{}) (interface{}, error) {
		jarvis.router.Emit(cmd)
		return true, nil
	})
}
