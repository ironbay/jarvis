defmodule Bot.Skill.Locale do
	use Bot.Skill

	def begin(bot, args) do
		{:ok, %{}}
	end

	def on({"locale.add", {action, template}, context}, bot, data) do
		{:ok, Map.put(data, action, template)}
	end

	def on({action, body, context}, bot, data) do
		case Map.get(data, action) do
			nil -> nil
			template ->
				formatted = EEx.eval_string(template, body |> Enum.into([]))
				IO.inspect(context)
				Bot.broadcast(bot, "chat.response", formatted, context)
		end
		{:ok, data}
	end
end
