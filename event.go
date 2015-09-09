package jarvis

import (
	"fmt"
	"log"
	"time"

	"github.com/dancannon/gorethink"
	"github.com/kr/pretty"
	"github.com/twinj/uuid"
)

type Event struct {
	ID      string  `json:"id" gorethink:"id,omitempty"`
	Model   Model   `json:"model" gorethink:"model"`
	Context Context `json:"context" gorethink:"context"`
	Type    string  `json:"type" gorethink:"type"`
	Created int64   `json:"created" gorethink:"created"`
}

type Model map[string]interface{}

type Context map[string]interface{}

func (this Context) Set(key string, value string) Context {
	this[key] = value
	return this
}

func Emit(event *Event) error {
	event.Created = time.Now().Unix()
	schema, ok := schemas[event.Type]
	if ok {
		event.ID = schema.Generate(event.Model)
	} else {
		event.ID = uuid.Formatter(uuid.NewV4(), uuid.CleanHyphen)
	}
	pretty.Print(event)
	fmt.Println("\n")
	err := gorethink.Table("events").Insert(event, gorethink.InsertOpts{Conflict: "replace"}).Exec(Rethink)
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
