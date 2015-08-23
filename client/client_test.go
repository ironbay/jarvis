package client

import (
	"log"
	"testing"
)

func TestClient(t *testing.T) {
	client := NewClient("http://localhost:3001")
	client.RegisterRegex("conversation.hello", "^hello jarvis")
	_, err := client.Once("conversation.hello")
	if err != nil {
		t.Fatal(err)
	}
	log.Println("HELLO")
}
