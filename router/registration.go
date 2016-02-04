package router

import (
	"github.com/ironbay/drs/drs-go"
	"github.com/ironbay/jarvis/event"
)

type Registration struct {
	Key     string `json:"key"`
	Once    bool   `json:"once"`
	Kind    string `json:"kind"`
	Chan    chan *event.Event
	Context drs.Dynamic `json:"context"`
}
