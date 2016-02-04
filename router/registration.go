package router

import (
	"github.com/ironbay/drs/drs-go"
	"github.com/ironbay/jarvis/event"
)

type Registration struct {
	Key     string                 `json:"key"`
	Once    bool                   `json:"once"`
	Kind    string                 `json:"kind"`
	Chan    chan *event.Event      `json:"-"`
	Hook    func(evt *event.Event) `json:"-"`
	Context drs.Dynamic            `json:"context"`
}
