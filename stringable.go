package main

import (
	"fmt"
	"log"
	"strings"

	"github.com/mitchellh/mapstructure"
)

type Stringable struct {
	Type     string `json:"type"`
	Template string `json:"template"`
}

var stringables = make(map[string]*Stringable)

func registerStringable(stringable *Stringable) {
	log.Println("Registered Stringable", stringable.Type)
	stringables[stringable.Type] = stringable
}

func (this *Stringable) Render(model map[string]interface{}) string {
	template := this.Template
	for key := range model {
		value := model[key]
		template = strings.Replace(template, "%"+strings.ToLower(key), fmt.Sprint(value), -1)
	}
	return template
}

func listenStringableRegistration() {
	for event := range Subscribe("register.stringable", false).Channel {
		stringable := new(Stringable)
		mapstructure.Decode(event.Model, stringable)
		registerStringable(stringable)
	}
}
