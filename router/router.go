package router

import (
	"github.com/ironbay/delta/uuid"
	"github.com/ironbay/drs/drs-go"
	"github.com/ironbay/jarvis/event"
)

type Router struct {
	registrations map[string]*Registration
}

func New() *Router {
	return &Router{
		registrations: make(map[string]*Registration, 0),
	}
}

func (this *Router) Add(input *Registration) {
	input.Key = uuid.Ascending()
	input.Chan = make(chan *event.Event)
	this.registrations[input.Key] = input
}

func (this *Router) Remove(key string) {
	match := this.registrations[key]
	close(match.Chan)
	delete(this.registrations, key)
}

func (this *Router) Process(evt *event.Event) {
	for _, reg := range this.registrations {
		match := compare(reg.Context, evt.Context)
		if match {
			if reg.Kind == evt.Kind {
				reg.Chan <- evt
			}
		}
		if reg.Once && match {
			this.Remove(reg.Key)
		}

	}
}

func compare(a drs.Dynamic, b drs.Dynamic) bool {
	for key, value := range a {
		if b[key] != value {
			return false
		}
	}
	return true
}
