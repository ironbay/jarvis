defmodule Jarvis.Package do
	use Bot.Skill

	@matches [
		{:fedex, ~r/\d{15}/i},
		{:fedex, ~r/\d{12}/i},
		{:fedex, ~r/\d{20}/i},
	]

	def begin(bot, []) do
		{:ok, {}}
	end

	def handle_cast_async({"package", body, context}, bot, data) do
		IO.inspect(body)
		:ok
	end

	def handle_cast_async({"email", %{body: body, key: key}, context}, bot, data) do
		@matches
		|> Enum.flat_map(&scan(&1, body))
		|> Enum.each(&Bot.cast(bot, "package", &1, context))
		:ok
	end

	defp scan({type, regex}, body) do
		Regex.scan(regex, body)
		|> Enum.map(&( %{type: type, number: &1}))
	end
end
