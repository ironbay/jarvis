defmodule Jarvis.Context do
	use Bot.Skill
	alias Delta.Mutation
	alias Delta.Dynamic

	def begin(bot, _args) do
		Bot.cast(bot, "regex.add", {"^reaction stats$", "slack.reaction.request"})
		{:ok, %{}}
	end

	def handle_cast_async({"slack.connect", slack, %{team: team}}, bot, state) do
		Mutation.combine(
			channels(slack.channels, team),
			users(slack.users, team)
		)
		|> Delta.mutation


		{:noreply, state}
	end

	def handle_cast_async({"chat.reaction", %{target: target, type: type},  context = %{sender: sender}}, _bot, state) when sender !== target do
		type = String.split(type, "::") |> List.first
		path = ["slack:reactions", context.team, target, type]
		previous = path |> Delta.query_path |> Dynamic.default(%{}, 0)
		Delta.merge(path, previous + 1)
		{:noreply, state}
	end

	def handle_cast_async({"slack.reaction.request", _, context}, bot, state) do
		result =
			["slack:reactions", context.team, context.sender]
			|> Delta.query_path
			|> Enum.sort_by(fn {key, value} -> value end, &>=/2)
			|> Stream.map(fn {key, value} -> ":#{key}: - #{value}" end)
			|> Enum.join("\n")
		Bot.cast(bot, "bot.message", result, context)
		{:noreply, state}
	end

	defp users(users, team) do
		context = "slack:#{team}"
		users
		|> Map.values
		|> Enum.reduce(Mutation.new, fn item, collect ->
			Mutation.merge(collect, ["context:info", context, "user", item.id], %{
				key: item.id,
				name: item.name,
				email: Map.get(item.profile, :email)
			})
		end)
	end

	defp channels(channels, team) do
		context = "slack:#{team}"
		channels
		|> Map.values
		|> Enum.reduce(Mutation.new, fn item, collect ->
			Mutation.merge(collect, ["context:info", context, "channel", item.id], %{
				key: item.id,
				name: item.name,
				creator: item.creator,
				created: item.created,
			})
		end)
	end
end
