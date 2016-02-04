package router

import (
	"encoding/json"
	"log"

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
	if input.Key == "" {
		input.Key = uuid.Ascending()
	}
	input.Chan = make(chan *event.Event)
	if input.Once {
		for _, reg := range this.registrations {
			if !reg.Once {
				continue
			}
			match := compare(input.Context, reg.Context)
			if match {
				this.Remove(reg.Key)
			}
		}
	}
	this.registrations[input.Key] = input
}

func (this *Router) Remove(key string) {
	match, ok := this.registrations[key]
	if !ok {
		return
	}
	close(match.Chan)
	delete(this.registrations, key)
}

func (this *Router) Emit(evt *event.Event) {
	data, _ := json.MarshalIndent(evt, "", "  ")
	log.Println(string(data))
	for _, reg := range this.registrations {
		match := compare(reg.Context, evt.Context)
		if match {
			if reg.Kind == evt.Kind {
				if reg.Hook != nil {
					reg.Hook(evt)
				} else {
					reg.Chan <- evt
				}
			}
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
