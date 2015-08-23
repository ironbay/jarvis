package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
	"path"

	"github.com/mitchellh/mapstructure"
	"github.com/twinj/uuid"
)

var schemas = make(map[string]*Schema)

type Schema struct {
	Type string
	Key  string
}

func registerSchema(input *Schema) {
	schemas[input.Type] = input
}

func save(event *Event) error {
	key := ID()
	event.Model["id"] = key
	if schema, ok := schemas[event.Type]; ok {
		key = fmt.Sprint(event.Model[schema.Key])
	}
	file := path.Join(getDirectory(event.Type), key+".json")
	bytes, err := json.Marshal(event)
	if err != nil {
		return err
	}
	return ioutil.WriteFile(file, bytes, 777)
}

func getDirectory(modelType string) string {
	result := path.Join("/var/lib/jarvis/", modelType)
	os.MkdirAll(result, 0777)
	return result
}

func ID() string {
	return uuid.Formatter(uuid.NewV4(), uuid.CleanHyphen)
}

func listenSchemaRegistration() {
	for event := range Subscribe("register.schema", false).Channel {
		schema := new(Schema)
		mapstructure.Decode(event.Model, schema)
		registerSchema(schema)
	}
}
