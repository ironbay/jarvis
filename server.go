package main

import (
	"log"

	"golang.org/x/net/websocket"

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
	result.pipe.Events.Connect = func(conn *drs.Connection) error {
		ws := conn.Raw.(*websocket.Conn)
		request := ws.Request()
		ip := request.RemoteAddr
		headers := request.Header["X-Forwarded-For"]
		if len(headers) > 0 {
			ip = headers[0]
		}
		conn.Set("ip", ip)
		conn.Set("registrations", map[string]*router.Registration{})
		log.Println(ip, "Connected")
		return nil
	}
	result.pipe.Events.Disconnect = func(conn *drs.Connection) error {
		registrations := conn.Get("registrations").(map[string]*router.Registration)
		for key := range registrations {
			result.router.Remove(key)
		}
		return nil
	}
	result.router = router.New()

	return result
}()

func main() {
	log.Println("Listening...")
	server.pipe.Listen()
}
