package cortex

import (
	"log"
	"regexp"
)

type RegexModel struct {
	Type     string `json:"type"`
	Regex    string `json:"regex"`
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
		if name == "" {
			continue
		}
		result[name] = match[i]
	}
	return result, true
}

var regexModels = make(map[string]*RegexModel, 0)

func registerRegexModel(model *RegexModel) {
	model.compile()
	log.Println("Registered", model.Type, model.Regex)
	regexModels[model.Type+"-"+model.Regex] = model
}

func init() {
}
