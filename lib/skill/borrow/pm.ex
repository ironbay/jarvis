defmodule Jarvis.Borrow.PM do
	use Bot.Skill
	@interval 1000 * 10

	def begin(bot, []) do
		accounts =
			["borrow:account:info"]
			|> Delta.query_path
			|> Map.values
		schedule(0)
		{:ok, accounts}
	end

	defp schedule(interval) do
		# Process.send_after(self, :poll, interval)
	end


	def handle_info(:poll, bot, accounts) do
		accounts
		|> ParallelStream.map(&check_inbox(&1, bot))
		|> Enum.to_list
		schedule(@interval)
		{:ok, accounts}
	end

	def check_inbox(%{"username" => username, "password" => password, "context" => context}, bot) do
		token = Reddit.token(username, password) |> IO.inspect
		results =
			["borrow:account:last", username]
			|> Delta.query_path()
			|> Reddit.inbox(token)
		if results != [] do
			%{created: created}= List.first(results)
			Delta.merge()
		end
	end

end
