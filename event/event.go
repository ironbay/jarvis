package event

import (
	"github.com/ironbay/drs/drs-go"
	"github.com/mitchellh/mapstructure"
)

type Event struct {
	Kind    string                 `json:"kind"`
	Data    map[string]interface{} `json:"data"`
	Context map[string]interface{} `json:"context"`
}

func From(input interface{}) *Event {
	cast, ok := input.(map[string]interface{})
	if !ok {
		return nil
	}
	result := new(Event)
	err := mapstructure.Decode(cast, result)
	if err != nil {
		return nil
	}
	return result
}

func Create(kind string, data drs.Dynamic, context drs.Dynamic) *Event {
	if data == nil {
		data = make(drs.Dynamic)
	}
	if context == nil {
		context = make(drs.Dynamic)
	}
	return &Event{
		kind,
		data,
		context,
	}
}
