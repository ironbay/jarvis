package jarvis

import (
	"fmt"
	"log"
	"strings"

	"github.com/mitchellh/mapstructure"
)

type Schema struct {
	Type string `json:"type"`
	Key  string `json:"key"`
}

var schemas = make(map[string]*Schema)

func registerSchema(schema *Schema) {
	log.Println("Registered Schema", schema.Type)
	schemas[schema.Type] = schema
}

func (this *Schema) Generate(model map[string]interface{}) string {
	template := this.Key
	for key := range model {
		value := model[key]
		template = strings.Replace(template, "%"+strings.ToLower(key), fmt.Sprint(value), -1)
	}
	return template
}

func listenSchemaRegistration() {
	for event := range Subscribe("register.schema", "").Channel {
		schema := new(Schema)
		mapstructure.Decode(event.Model, schema)
		registerSchema(schema)
	}
}
