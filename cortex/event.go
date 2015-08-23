package main

type Event struct {
	Model   Model   `json:"model"`
	Context Context `json:"context"`
	Type    string  `json:"type"`
}

type Model map[string]interface{}

type Context map[string]interface{}

func (this Context) Set(key string, value string) Context {
	this[key] = value
	return this
}
