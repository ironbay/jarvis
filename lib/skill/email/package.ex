defmodule Jarvis.Package do
	use Bot.Skill

	@matches [
		{:fedex, ~r/\d{14}/i}
	]

	def begin(bot, []) do
		{:ok, {}}
	end

	def handle_cast_async({"email", %{body: body, key: key}, context}, bot, data) do

		:ok
	end
end
