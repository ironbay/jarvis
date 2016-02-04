package client

import (
	"log"
	"testing"

	"github.com/ironbay/drs/drs-go"
	"github.com/ironbay/jarvis/event"
)

func TestClient(t *testing.T) {
	client := New()
	client.On("convo.hello", drs.Dynamic{}, func(evt *event.Event) {
		log.Println("Hello!")
	})
	select {}
}
