defmodule Bot.Skill.Regex do
	use Bot.Skill

	def begin(bot, args) do
		{:ok, %{}}
	end

	def on({"regex.add", {pattern, action}, _context}, bot, data) do
		{:ok, compiled} = Regex.compile("(?i)#{pattern}")
		next = Map.put(data, compiled, action)
		{:ok, next}
	end

	def on({"chat.message", %{text: text }, context}, bot, data) do
		data
		|> Enum.each(fn({regex, action}) ->
			case Regex.named_captures(regex, text) do
				nil -> :ok
				data ->
					parsed = for {key, val} <- data, into: %{}, do: {String.to_atom(key), val}
					Bot.broadcast(bot, action, parsed |> Map.put(:raw, text), context)
			end
		end)
		{:ok, data}
	end
end
