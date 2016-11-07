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
		user = Bot.call(bot, "user.who", %{}, context)
		IO.inspect(body)
		:ok
	end

	def handle_cast_async({"email", %{content: content, key: key}, context}, bot, data) do
		@matches
		|> Enum.flat_map(&scan(&1, content))
		|> Enum.uniq_by(&Map.get(&1, :number))
		|> Enum.each(&Bot.cast(bot, "package", &1, context))
		:ok
	end

	defp scan({type, regex}, content) do
		Regex.scan(regex, content)
		|> Enum.map(&( %{type: type, number: List.first(&1)}))
	end
end
