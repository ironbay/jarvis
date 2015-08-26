package jarvis

import (
	"log"

	"github.com/dancannon/gorethink"
)

type Subscription struct {
	Type    string
	Channel chan Event
	Process string
	Cursor  *gorethink.Cursor
}

var subscriptions = make(map[string]*Subscription, 0)

func Subscribe(modelType string, process string) *Subscription {
	log.Println("New Subscriber For", modelType, process)
	result := Subscription{
		Type:    modelType,
		Channel: make(chan Event),
		Process: process,
	}
	query := gorethink.Table("events").Filter(
		gorethink.Row.Field("type").Eq(modelType),
	)
	if process != "" {
		log.Println("Routing Process", process)
		context := gorethink.Row.Field("context")
		query = query.Filter(gorethink.Or(
			context.Field("process").Eq(process),
			context.Field("type").Eq("broadcast"),
		))
	}
	result.Cursor, _ = query.Changes().Run(Rethink)
	go result.pull()
	return &result
}

func (this *Subscription) pull() {
	var result struct {
		Event Event `gorethink:"new_val"`
	}
	for this.Cursor.Next(&result) {
		this.Channel <- result.Event
	}
}

func (this *Subscription) Close() {
	this.Cursor.Close()
	log.Println("Closed connection to", this.Type, this.Process)
	close(this.Channel)
}
