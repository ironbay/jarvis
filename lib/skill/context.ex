defmodule Jarvis.Context do
	use Bot.Skill
	alias Delta.Mutation

	def begin(_bot, _args) do
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
