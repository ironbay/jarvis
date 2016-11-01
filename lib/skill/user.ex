defmodule Bot.Skill.User do
	alias Delta.Plugin.Fact
	use Bot.Skill

	def begin(bot, []) do
		Bot.cast(bot, "regex.add", {"^register$", "user.register"})
		Bot.cast(bot, "regex.add", {"who am i", "user.who"})
		Bot.cast(bot, "regex.add", {"my name is (?<name>.+)", "user.register.name"})
		Bot.cast(bot, "regex.add", {"call me (?<name>.+)", "user.register.name"})
		Bot.cast(bot, "regex.add", {".+@.+", "chat.email"})
		Bot.cast(bot, "locale.add", {"bot.register.email", "What is your email?"})
		Bot.cast(bot, "locale.add", {"bot.user.success", "Great thanks!"})
		Bot.cast(bot, "locale.add", {"bot.user.already", "You have already linked this <%= type %> account"})
		Bot.cast(bot, "locale.add", {"bot.ack", "Sounds good"})
		{:ok, Delta.start_session(Delta, "jarvis")}
	end

	def handle_cast_async({"user.register", _body, context = %{type: type, sender: sender}}, bot, session) do
		case from_context(session, context) do
			_ ->
				Bot.cast(bot, "bot.register.email", %{}, context)
				{_, %{raw: email}, _} = Bot.wait(bot, context, ["chat.email"])
				key =
					case from_email(session, email) do
						nil ->
							key = Delta.UUID.ascending()
							Bot.cast(bot, "bot.message", "Looks like you're new, we've created a new account for you: #{key}", context)
							Fact.add_fact(session, key, "user:email", email)
							key
						key -> key |> IO.inspect
					end

				Fact.add_fact(session, sender, "context:type", type)
				Fact.add_fact(session, sender, "user:key", key)


				Bot.cast(bot, "bot.user.success", %{}, context)
			data ->
				IO.inspect(data)
				Bot.cast(bot, "bot.user.already", %{type: type},context)
		end
		:ok
	end

	def handle_cast_async({"user.register.name", %{name: name}, context}, bot, session) do
		case from_context(session, context) do
			nil -> :skip
			{key, existing} ->
				Delta.Plugin.Fact.del_fact(session, key, "user:name", existing)
				Delta.Plugin.Fact.add_fact(session, key, "user:name", name)
				Bot.cast(bot, "bot.ack", %{}, context)
		end
		:ok
	end

	def handle_call({"user.who", _body, context}, bot, session) do
		{:ok, from_context(session, context)}
	end

	def handle_cast({"user.who", _body, context}, bot, session) do
		{number, name} = from_context(session, context)
		Bot.cast(bot, "bot.message", "#{number} - #{name}", context)
		:ok
	end

	defp from_context(session, %{type: type, sender: sender}) do
		Delta.Plugin.Fact.query(session, [
			[:key, :name],
			[sender, "user:key", :key],
			[:key, "user:name", :name],
		])
		|> List.first
	end

	defp from_email(session, email) do
		Delta.Plugin.Fact.query(session, [
			[:key],
			[:key, "user:email", email]
		])
		|> List.first
	end

end
