package cortex

import (
	"encoding/json"
	"log"

	"golang.org/x/net/websocket"
)

type Connection struct {
	*websocket.Conn
	Subscription *Subscription
}

func (this *Connection) listen() {
	go func() {
		for {
			buf := ""
			if err := websocket.Message.Receive(this.Conn, &buf); err != nil {
				log.Println(err)
				break
			}
		}
	}()
	for event := range this.Subscription.Channel {
		bytes, _ := json.Marshal(event)
		this.Conn.Write(bytes)
	}
}
