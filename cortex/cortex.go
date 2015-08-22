package cortex

func Run() {
	registerRegexModel(&RegexModel{"debug.echo", "echo (.+)", nil})
	startServer()
}
