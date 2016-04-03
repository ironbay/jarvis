package router

import (
	"log"

	"github.com/ironbay/delta/uuid"
	"github.com/ironbay/drs/drs-go"
	"github.com/ironbay/dynamic"
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
	input.Chan = make(chan *drs.Command)
	if input.Once {
		this.clear(input.Context)
	}
	this.registrations[input.Key] = input
}

func (this *Router) clear(ctx drs.Dynamic) {
	for _, reg := range this.registrations {
		if !reg.Once {
			continue
		}
		match := compare(ctx, reg.Context)
		if match {
			this.Remove(reg.Key)
		}
	}
}

func (this *Router) Remove(key string) {
	match, ok := this.registrations[key]
	if !ok {
		return
	}
	log.Println("Unregistered", match.Action)
	close(match.Chan)
	delete(this.registrations, key)
}

func (this *Router) Emit(cmd *drs.Command) {
	// data, _ := json.MarshalIndent(evt, "", "  ")
	// log.Println(string(data))
	ctx := dynamic.Object(cmd.Map(), "context")
	for _, reg := range this.registrations {
		match := compare(reg.Context, ctx)
		if match {
			if reg.Action == cmd.Action {
				if reg.Hook != nil {
					reg.Hook(cmd)
				} else {
					reg.Chan <- cmd
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
