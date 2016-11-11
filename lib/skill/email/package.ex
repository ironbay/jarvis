defmodule Jarvis.Package do
	use Bot.Skill

	@matches [
		{:fedex, ~r/\d{15}/i},
		{:fedex, ~r/\d{12}/i},
		{:fedex, ~r/\d{20}/i},
	]

	def begin(bot, []) do
		Bot.cast(bot, "regex.add", {"^list packages$", "package.list"})
		{:ok, {}}
	end

	def handle_cast_async({"package.list", _, context}, bot, data) do
		user = Bot.call(bot, "user.who", %{}, context)
		Delta.query_fact([
			[:package],
			[:account, "user:key", user],
			[:account, "context:type", "contextio"],
			[:account, "email:key", :email],
			[:email, "package:number", :package]
		])
		|> IO.inspect
		:ok
	end


	def handle_cast_async({"email", %{content: content, key: key}, context}, bot, data) do
		@matches
		|> Enum.flat_map(&scan(&1, content))
		|> Enum.uniq_by(&Map.get(&1, :number))
		|> Enum.map(fn package ->
			Delta.add_fact(key, "package:number", package.number)
			Delta.add_fact(key, "package:type", Atom.to_string(package.type))
			Bot.cast(bot, "package", package, context)
		end)
		:ok
	end

	defp scan({type, regex}, content) do
		Regex.scan(regex, content)
		|> Enum.map(&( %{type: type, number: List.first(&1)}))
	end
end
