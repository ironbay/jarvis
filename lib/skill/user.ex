defmodule Bot.Skill.User do
	use Bot.Skill

	def begin(bot, []) do
		Bot.cast(bot, "regex.add", {"^register$", "user.register"})
		Bot.cast(bot, "regex.add", {"^identify$", "user.identify"})
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
			# If unregistered
			nil ->
				# Ask for email
				Bot.cast(bot, "bot.register.email", %{}, context)
				{_, %{raw: email}, _} = Bot.wait(bot, context, ["chat.email"])
				key =
					case from_email(email) do
						# Create a new user
						nil -> create_user(bot, email, context)
						key -> key
					end
					IO.inspect(key)
				identify(bot, context)
				|> register_context(key)

				Bot.cast(bot, "bot.user.success", %{}, context)
			data ->
				Bot.cast(bot, "bot.user.already", %{type: type},context)
		end
		:ok
	end

	def handle_cast({"user.who", _body, context}, bot, _data) do
		[key] = from_context(context)
		Bot.cast(bot, "bot.message", "#{key}", context)
		:ok
	end

	def handle_call({"user.who", context, _}, bot, _data) do
		{:reply, from_context(context) |> List.first}
	end

	def handle_cast({"user.identify", _body, context}, bot, _data) do
		Bot.cast(bot, "bot.message", inspect(identify(bot, context)), context)
		:ok
	end

	defp create_user(bot, email, context) do
		key = Delta.UUID.ascending()
		Bot.cast(bot, "bot.message", "Looks like you're new, we've created a new account for you: #{key}", context)
		Delta.add_fact(key, "user:email", email)
		key
	end

	defp register_context(context, user) do
		{sender, rest} = Map.pop(context, :sender)
		Delta.add_fact(sender, "user:key", user)
		rest
		|> Enum.each(fn {key, value} ->
			Delta.add_fact(sender, "context:#{key}", value)
		end)
	end

	defp identify(bot, context) do
		Bot.call(bot, "user.identify", context)
	end

	defp from_context(%{sender: sender}) do
		[
			[:key],
			[sender, "user:key", :key],
		]
		|> Delta.query_fact
		|> List.first
	end

	defp from_email(email) do
		Delta.query_fact([
			[:key],
			[:key, "user:email", email]
		])
		|> List.first
		|> List.first
	end

end
