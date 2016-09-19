defmodule Bot.Skill.Greeter do
	use Bot.Skill

	def begin(bot, args) do
		Bot.broadcast(bot, "regex.add", {"^hello$", "chat.hello"})
		Bot.broadcast(bot, "regex.add", {"good", "emotion.good"})
		Bot.broadcast(bot, "regex.add", {"bad", "emotion.bad"})

		Bot.broadcast(bot, "locale.add", {"chat.greeting", "Hey there! How are you?"})
		Bot.broadcast(bot, "locale.add", {"bot.excitement", "That's great to hear!"})
		Bot.broadcast(bot, "locale.add", {"bot.sympathy", "I'm sorry to hear that :("})
		{:ok, %{}}
	end

	def on({"chat.hello", _body, context}, bot, data) do
		Bot.broadcast(bot, "chat.greeting", %{}, context)
		case Bot.wait(bot, 1, ["emotion.good", "emotion.bad"]) do
			{"emotion.good", _, _} -> Bot.broadcast(bot, "bot.excitement", %{}, context)
			{"emotion.bad", _, _} -> Bot.broadcast(bot, "bot.sympathy", %{}, context)
		end
		{:ok, data}
	end
end
