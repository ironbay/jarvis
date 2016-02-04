package stream

import (
	"github.com/ironbay/delta/uuid"
	"github.com/ironbay/jarvis/event"
)

type Stream struct {
	Key  string
	Chan chan *event.Event
}

func New() *Stream {
	return &Stream{
		Key:  uuid.Ascending(),
		Chan: make(chan *event.Event),
	}
}
