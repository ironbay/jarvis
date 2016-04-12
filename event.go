package main

import (
	"github.com/ironbay/drs/drs-go"
	"github.com/ironbay/go-util/console"
)

func init() {
	jarvis.server.On("*", func(msg *drs.Message) (interface{}, error) {
		console.JSON(msg.Command)
		jarvis.router.Emit(msg.Command)
		return true, nil
	})
}
