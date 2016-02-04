package main

import (
	"log"

	"github.com/ironbay/drs/drs-go"
	"github.com/ironbay/drs/drs-go/transport/ws"
	"github.com/ironbay/jarvis/router"
)

type Server struct {
	router *router.Router
	pipe   *drs.Pipe
}

var server = func() *Server {
	result := new(Server)
	result.pipe, _ = ws.New(make(drs.Dynamic))
	result.router = router.New()
	return result
}()

func main() {
	log.Println("Listening...")
	server.pipe.Listen()
}
