package main

import (
	"regexp"

	"github.com/ironbay/dynamic"
	"github.com/ironbay/jarvis/event"
	"github.com/ironbay/jarvis/router"
)

type ChatRegex struct {
	pattern string
	kind    string
	regex   *regexp.Regexp
}

func init() {
	patterns := map[string]*ChatRegex{}
	server.router.Add(&router.Registration{
		Kind: "chat.regex",
		Hook: func(evt *event.Event) {
			cr := &ChatRegex{
				pattern: "(?i)" + evt.Data["pattern"].(string),
				kind:    evt.Data["kind"].(string),
			}
			cr.regex = regexp.MustCompile(cr.pattern)
			patterns[cr.pattern] = cr
		},
	})

	server.router.Add(&router.Registration{
		Kind: "chat.message",
		Hook: func(inner *event.Event) {
			text := inner.Data["text"].(string)
			for _, cr := range patterns {
				match := cr.regex.FindStringSubmatch(text)
				if len(match) == 0 {
					continue
				}
				data := dynamic.Empty()
				for i, name := range cr.regex.SubexpNames() {
					if name == "" {
						continue
					}
					data[name] = match[i]
				}
				server.router.Emit(&event.Event{
					Kind:    cr.kind,
					Data:    data,
					Context: inner.Context,
				})
			}
		},
	})
}
