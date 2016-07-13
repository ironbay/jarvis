package main

import (
	"encoding/json"
	"io"
	"log"
	"net/http"

	"golang.org/x/net/websocket"

	"github.com/ironbay/drs/drs-go"
	"github.com/ironbay/drs/drs-go/plugins/ping"
	"github.com/ironbay/drs/drs-go/transports/ws"
	"github.com/ironbay/dynamic"
	"github.com/ironbay/jarvis/router"
)

type Jarvis struct {
	router *router.Router
	server *drs.Server
}

var jarvis = func() *Jarvis {
	result := new(Jarvis)
	result.server = drs.NewServer(ws.New(dynamic.Empty()))
	ping.Attach(result.server.Processor)
	result.server.OnConnect(func(conn *drs.Connection, raw io.ReadWriteCloser) error {
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
	})
	result.server.OnDisconnect(func(conn *drs.Connection) {
		match, _ := conn.Cache.Get("registrations")
		registrations := match.(map[string]*router.Registration)
		for key := range registrations {
			result.router.Remove(key)
		}
	})
	result.router = router.New()

	return result
}()

func main() {
	log.Println("Listening...")
	http.HandleFunc("/command", func(w http.ResponseWriter, req *http.Request) {
		d := json.NewDecoder(req.Body)
		d.UseNumber()
		cmd := new(drs.Command)
		err := d.Decode(cmd)
		if err != nil {
			response(w, 500, err.Error())
			return
		}
		res, err := jarvis.server.Process(cmd, new(drs.Connection))
		if err != nil {
			response(w, 500, err.Error())
			return
		}
		response(w, 200, res)
	})
	jarvis.server.Listen(":12000")
}

func response(w http.ResponseWriter, status int, input interface{}) {
	data, _ := json.Marshal(input)
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	w.Write(data)
}
