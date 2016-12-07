defmodule Jarvis.Media.Chromecast do
	use Bot.Skill

	def begin(bot, [ip]) do
		Bot.cast(bot, "regex.add", {"cast speech (?P<text>.+)", "chromecast.speech"})
		{:ok, %{
			ip: ip,
		}}
	end

	def handle_cast_async({"chromecast.speech", %{text: text}, context}, bot, %{ip: ip}) do
		Bot.cast(bot, "bot.message", "Casting '#{text}' to #{ip}", context)
		say(text, ip)
		:ok
	end

	def handle_call({"chromecast.speak", text, _context}, bot, %{ip: ip}) do
		say(text, ip)
		:ok
	end

	def handle_cast_async({"bot.broadcast", text, _context}, bot, %{ip: ip}) do
		say(text, ip)
		:ok
	end

	defp say(text, ip) do
		text = Regex.replace(~r/http[^\s]+/, text, "")
		System.cmd("aws", [
			"polly",
			"synthesize-speech",
			"--output-format", "mp3",
			"--voice-id", "Brian",
			"--text", text,
			"speech.mp3",
		])
		System.cmd("stream2chromecast", ["-devicename", ip, "./speech.mp3"])
	end

end
