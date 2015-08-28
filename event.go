package jarvis

import (
	"fmt"
	"log"
	"time"

	"github.com/dancannon/gorethink"
	"github.com/kr/pretty"
)

type Event struct {
	Model   Model   `json:"model" gorethink:"model"`
	Context Context `json:"context" gorethink:"context"`
	Type    string  `json:"type" gorethink:"type"`
	Created int64   `json:"created" gorethink:"created"`
	ID      string  `json:"id" gorethink:"id,omitempty"`
}

type Model map[string]interface{}

type Context map[string]interface{}

func (this Context) Set(key string, value string) Context {
	this[key] = value
	return this
}

func Emit(event *Event) error {
	pretty.Print(event)
	fmt.Println("\n")
	event.Created = time.Now().Unix()
	err := gorethink.Table("events").Insert(event).Exec(Rethink)
	if err != nil {
		log.Println(err)
	}
	stringable, ok := stringables[event.Type]
	if !ok {
		return nil
	}
	return Emit(&Event{
		Context: event.Context,
		Type:    "conversation.stringable",
		Model:   Model{"message": stringable.Render(event.Model)},
	})
}
