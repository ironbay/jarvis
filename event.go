package main

import (
	"github.com/ironbay/drs/drs-go"
	"github.com/ironbay/go-util/console"
)

func init() {
	jarvis.server.On("*", func(cmd *drs.Command, conn *drs.Connection, ctx map[string]interface{}) (interface{}, error) {
		console.JSON(cmd)
		jarvis.router.Emit(cmd)
		return true, nil
	})
}
