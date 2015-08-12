package cortex

import (
	"log"

	"github.com/renstrom/fuzzysearch/fuzzy"
)

func init() {
	Pipe.Global("\\@(\\w+).*", func(l *Context, args []string) {
		tags := make([]Tag, 0)
		Database.Get(&tags)
		names := make([]string, len(tags))
		kv := make(map[string]string)
		for n, tag := range tags {
			names[n] = tag.Name
			kv[tag.Name] = tag.Number
		}
		log.Println(args[1])

		matches := fuzzy.Find(args[1], names)
		if len(matches) == 0 {
			return
		}
		Twilio.Send(kv[matches[0]], l.User+": "+args[0])
	})

	Pipe.Global("notify (\\w+) (\\d+)", func(context *Context, args []string) {
		model := Tag{
			Name:   args[1],
			Number: args[2],
		}
		Event.Emit(&model, context)
	})
}

type Tag struct {
	Name   string
	Number string
}

func (s *Tag) Key() string {
	return s.Name
}

func (s *Tag) Alert() string {
	return "Notifying " + s.Name + " at " + s.Number
}
