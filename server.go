package main

import (
	"io"
	"log"

	"golang.org/x/net/websocket"

	"github.com/ironbay/drs/drs-go"
	"github.com/ironbay/drs/drs-go/transports/ws"
	"github.com/ironbay/dynamic"
	"github.com/ironbay/jarvis/router"
)

type Server struct {
	router *router.Router
	pipe   *drs.Pipe
}

var server = func() *Server {
	result := new(Server)
	result.pipe = drs.New(ws.New(dynamic.Empty()))
	result.pipe.OnConnect = func(conn *drs.Connection, raw io.ReadWriteCloser) error {
		ws := raw.(*websocket.Conn)
		request := ws.Request()
		ip := request.RemoteAddr
		headers := request.Header["X-Forwarded-For"]
		if len(headers) > 0 {
			ip = headers[0]
		}
		conn.Cache.Set("ip", ip)
		conn.Cache.Set("registrations", map[string]*router.Registration{})
		log.Println(ip, "Connected")
		return nil
	}
	result.pipe.OnDisconnect = func(conn *drs.Connection) {
		match, _ := conn.Cache.Get("registrations")
		registrations := match.(map[string]*router.Registration)
		for key := range registrations {
			result.router.Remove(key)
		}
	}
	result.router = router.New()

	return result
}()

func main() {
	log.Println("Listening...")
	server.pipe.Listen()
}
