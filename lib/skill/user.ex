defmodule Bot.Skill.User do
	use Bot.Skill

	def begin(bot, []) do
		Bot.cast(bot, "regex.add", {"^register$", "user.register"})
		Bot.cast(bot, "regex.add", {"who am i", "user.who"})
		Bot.cast(bot, "regex.add", {"my name is (?<name>.+)", "user.register.name"})
		Bot.cast(bot, "regex.add", {"call me (?<name>.+)", "user.register.name"})
		Bot.cast(bot, "regex.add", {"(?P<number>\\d{10})", "user.register.phone"})
		Bot.cast(bot, "regex.add", {".+@.+", "chat.email"})
		Bot.cast(bot, "regex.add", {"yes", "chat.yes"})
		Bot.cast(bot, "regex.add", {"no", "chat.no"})

		Bot.cast(bot, "locale.add", {"bot.register.email", "What is your email?"})
		Bot.cast(bot, "locale.add", {"bot.success", "Great thanks!"})
		Bot.cast(bot, "locale.add", {"bot.user.already", "You have already linked this <%= type %> account"})
		Bot.cast(bot, "locale.add", {"bot.ack", "Sounds good"})
		Bot.cast(bot, "locale.add", {"bot.rejected", "Oh okay"})
		{:ok, {}}
	end

	def handle_cast_async({"user.register", _body, context = %{type: type, sender: sender}}, bot, _data) do
		case from_context(context) do
			nil ->
				Bot.cast(bot, "bot.register.email", %{}, context)
				{_, %{raw: email}, _} = Bot.wait(bot, context, ["chat.email"])
				key =
					case from_email(email) do
						nil ->
							key = Delta.UUID.ascending()
							Bot.cast(bot, "bot.message", "Looks like you're new, we've created a new account for you: #{key}", context)
							Delta.add_fact(key, "user:email", email)
							key
						key -> key
					end

				Delta.add_fact(sender, "context:type", type)
				Delta.add_fact(sender, "user:key", key)

				Bot.cast(bot, "bot.user.success", %{}, context)
			data ->
				Bot.cast(bot, "bot.user.already", %{type: type},context)
		end
		:ok
	end

	def handle_cast_async({"user.register.name", %{name: name}, context}, bot, _data) do
		case from_context(context) do
			nil -> :skip
			[key] ->
				Delta.add_fact(key, "user:name", name)
				Bot.cast(bot, "bot.ack", %{}, context)
		end
		:ok
	end


	def handle_cast_async({"user.register.phone", %{number: number}, context}, bot, _data) do
		case from_context(context) do
			nil -> :skip
			{key, name} ->
				Bot.cast(bot, "bot.message", "#{name || "Hey"}, is #{number} your number?", context)
				case Bot.wait(bot, context, ["chat.yes", "chat.no"]) do
					{"chat.no", _, _} -> :skip
						Bot.cast(bot, "bot.rejected", %{}, context)
					{"chat.yes", _, _} ->
						Delta.add_fact(key, "user:phone", number)
						Bot.cast(bot, "bot.success", %{}, context)
				end
		end
		:ok
	end

	def handle_call({"user.who", _body, context}, bot, _data) do
		[key] = from_context(context)
		{:ok, key}
	end

	def handle_cast({"user.who", _body, context}, bot, _data) do
		[key] = from_context(context)
		Bot.cast(bot, "bot.message", "#{key}", context)
		:ok
	end

	defp from_context(%{type: type, sender: sender}) do
		Delta.query_fact([
			[:key],
			[sender, "user:key", :key],
		])
		|> List.first
	end

	defp from_email(email) do
		Delta.query_fact([
			[:key],
			[:key, "user:email", email]
		])
		|> List.zip
		|> List.first
	end

end
