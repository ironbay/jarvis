package jarvis

import (
	"log"
	"regexp"
)

type Subscription struct {
	ID      string
	Type    string
	Once    bool
	Channel chan *Event
	Context Context
	closed  bool
}

var subscriptions = make(map[string]*Subscription, 0)

func Subscribe(modelType string, once bool, contextType string) *Subscription {
	log.Println("New Subscriber For", modelType, contextType)
	result := Subscription{
		ID:      ID(),
		Type:    modelType,
		Once:    once,
		Channel: make(chan *Event),
		Context: make(Context),
	}
	if contextType != "" {
		result.Context["type"] = contextType
	}
	subscriptions[result.ID] = &result
	return &result
}

func (this *Subscription) MatchType(input string) bool {
	if input == this.Type {
		return true
	}
	ok, _ := regexp.MatchString(this.Type, input)
	return ok
}

func (this *Subscription) MatchContext(context Context) bool {
	if context["type"] == "broadcast" {
		return true
	}
	for key, value := range this.Context {
		compare := context[key]
		if compare != value {
			return false
		}
	}
	return true
}

func (this *Subscription) Push(event *Event) {
	this.Channel <- event
	if this.Once {
		this.Close()
	}
}

func (this *Subscription) Close() {
	if this.closed {
		return
	}
	close(this.Channel)
	delete(subscriptions, this.ID)
	this.closed = true
}

func Emit(event *Event) {
	save(event)
	log.Println("Emitting", event.Type)
	for key := range subscriptions {
		subscription := subscriptions[key]
		if subscription.MatchType(event.Type) && subscription.MatchContext(event.Context) {
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
