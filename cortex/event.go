package cortex

type Event struct {
	Model   Model   `json:"model"`
	Context Context `json:"context"`
	Type    string  `json:"type"`
}

type Model map[string]interface{}

type Context map[string]interface{}
