package jarvis

func Run() {
	subscription := Subscribe("conversation.message", false, "")
	go func() {
		for event := range subscription.Channel {
			for _, regex := range regexModels {
				input, ok := event.Model["message"]
				if !ok {
					continue
				}
				model, ok := regex.Match(input.(string))
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
	registerRegex(&RegexModel{"debug.echo", "echo (?P<message>.+)", nil})
	registerStringable(&Stringable{"debug.echo", "%message"})

	go listenStringableRegistration()
	go listenRegexRegistration()

	startServer()
}