package client

import (
	"log"
	"testing"

	"github.com/ironbay/jarvis/cortex"
)

func TestClient(t *testing.T) {
	client := NewClient("http://localhost:3001")
	client.RegisterRegex(cortex.RegexModel{Type: "conversation.hello", Regex: "^hello jarvis"})
	_, err := client.Once("conversation.hello")
	if err != nil {
		t.Fatal(err)
	}
	log.Println("HELLO")
}
