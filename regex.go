package main

import (
	"regexp"

	"github.com/ironbay/drs/drs-go"
	"github.com/ironbay/dynamic"
	"github.com/ironbay/jarvis/router"
)

type ChatRegex struct {
	pattern string
	action  string
	regex   *regexp.Regexp
}

func init() {
	patterns := map[string]*ChatRegex{}
	jarvis.router.Add(&router.Registration{
		Action: "chat.regex",
		Hook: func(cmd *drs.Command) {
			body := cmd.Map()
			pattern := dynamic.String(body, "data", "pattern")
			action := dynamic.String(body, "data", "action")
			cr := &ChatRegex{
				pattern: "(?i)" + pattern,
				action:  action,
			}
			cr.regex = regexp.MustCompile(cr.pattern)
			patterns[cr.pattern] = cr
		},
	})

	jarvis.router.Add(&router.Registration{
		Action: "chat.message",
		Hook: func(cmd *drs.Command) {
			body := cmd.Map()
			text := dynamic.String(body, "data", "text")
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
				jarvis.router.Emit(&drs.Command{
					Action: cr.action,
					Body: dynamic.Build(
						"data", data,
						"context", dynamic.Get(body, "context"),
					),
				})
			}
		},
	})
}
