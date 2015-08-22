package cortex

import (
	"log"
	"regexp"
)

type RegexModel struct {
	Type     string
	Regex    string
	compiled *regexp.Regexp
}

func (this *RegexModel) compile() {
	this.compiled = regexp.MustCompile(this.Regex)
}

func (this *RegexModel) Match(input string) (Model, bool) {
	result := make(Model)
	match := this.compiled.FindStringSubmatch(input)
	if len(match) == 0 {
		return nil, false
	}
	for i, name := range this.compiled.SubexpNames() {
		result[name] = match[i]
	}
	return result, true
}

var regexModels = make([]*RegexModel, 0)

func registerRegexModel(model *RegexModel) {
	model.compile()
	log.Println("Registered", model.Type, model.Regex)
	regexModels = append(regexModels, model)
}

func init() {
	subscription := Subscribe("conversation.message", false)
	go func() {
		for event := range subscription.Channel {
			for _, regex := range regexModels {
				model, ok := regex.Match(event.Model["message"].(string))
				if !ok {
					continue
				}
				Emit(&Event{
					Type:    regex.Type,
					Context: event.Context,
					Model:   model,
				})
			}
		}
	}()
}
