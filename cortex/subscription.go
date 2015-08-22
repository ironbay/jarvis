package cortex

import (
	"log"

	"github.com/twinj/uuid"
)

type Subscription struct {
	ID      string
	Type    string
	Once    bool
	Channel chan *Event
}

var subscriptions = make(map[string]*Subscription, 0)

func Subscribe(modelType string, once bool) *Subscription {
	log.Println("New Subscriber For", modelType)
	result := Subscription{
		ID:      uuid.Formatter(uuid.NewV4(), uuid.CleanHyphen),
		Type:    modelType,
		Once:    once,
		Channel: make(chan *Event),
	}
	subscriptions[result.ID] = &result
	return &result
}

func (this *Subscription) Match(input string) bool {
	return input == this.Type
}

func (this *Subscription) Push(event *Event) {
	this.Channel <- event
	if this.Once {
		this.Close()
	}
}

func (this *Subscription) Close() {
	close(this.Channel)
	delete(subscriptions, this.ID)
}

func Emit(event *Event) {
	log.Println("Emitting", event.Type)
	for key := range subscriptions {
		subscription := subscriptions[key]
		if subscription.Match(event.Type) {
			subscription.Push(event)
		}
	}
	stringable, ok := stringables[event.Type]
	if !ok {
		return
	}
	Emit(&Event{
		Context: event.Context,
		Type:    "conversation.stringable",
		Model:   Model{"message": stringable.Render(event.Model)},
	})
}
