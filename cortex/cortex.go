package cortex

func Run() {
	registerRegexModel(&RegexModel{"debug.echo", "echo (?P<message>.+)", nil})
	startServer()
}
