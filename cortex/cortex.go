package cortex

func Run() {
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
	registerRegexModel(&RegexModel{"debug.echo", "echo (?P<message>.+)", nil})
	registerStringable(&Stringable{"debug.echo", "Respond: %message"})

	startServer()
}
