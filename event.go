package main

import "github.com/ironbay/drs/drs-go"

func init() {
	jarvis.server.On("*", func(msg *drs.Message) (interface{}, error) {
		jarvis.router.Emit(msg.Command)
		return true, nil
	})
}
