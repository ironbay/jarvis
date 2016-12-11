defmodule Jarvis.Presence do
	use Bot.Skill
	@interval 5 * 1000

	def begin(_bot, _args) do
		{:ok, true}
	end

	def handle_cast_async({"wifi.connect", _, context}, bot, data) do
		IO.inspect("LALALAL")
		Bot.call(bot, "chromecast.speak", "Welcome home", context)
		:ok
	end


end
