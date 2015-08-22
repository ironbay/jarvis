package cortex

import (
	"fmt"
	"strings"
)

type Stringable struct {
	Type     string `json:"type"`
	Template string `json:"template"`
}

var stringables = make(map[string]*Stringable)

func registerStringable(stringable *Stringable) {
	stringables[stringable.Type] = stringable
}

func (this *Stringable) Render(model Model) string {
	template := this.Template
	for key := range model {
		value := model[key]
		template = strings.Replace(template, "%"+strings.ToLower(key), fmt.Sprint(value), -1)
	}
	return template
}
