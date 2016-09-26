defmodule Jarvis.Reddit.Poller do
	use Bot.Skill
	@interval 1 * 1000 * 60 * 5
	@base "https://www.reddit.com"

	def begin(bot, [subreddit]) do
		Bot.cast(bot, "locale.broadcast", {"reddit.link", "<%= title %> - <%= url %>"})
		%{id: id} = get_post(subreddit)
		schedule(@interval)
		{:ok, %{
			subreddit: subreddit,
			last: id,
		}}
	end

	defp schedule(interval) do
		Process.send_after(self(), {:poll}, interval)
	end

	def handle_info({:poll}, bot, state = %{subreddit: subreddit, last: last}) do
		post = %{id: id} = get_post(subreddit)
		if last != id do
			Bot.cast(bot, "reddit.link", post)
		end
		schedule(@interval)
		{:noreply, Kernel.put_in(state, [:data, :last], id)}
	end

	def get_post(subreddit) do
		HTTPoison.get!("#{@base}/r/#{subreddit}.json")
		|> Map.get(:body)
		|> Poison.decode!(as: %{})
		|> Kernel.get_in(["data", "children"])
		|> Stream.map(&Kernel.get_in(&1, ["data"]))
		|> Stream.filter(&validate(&1))
		|> Stream.take(1)
		|> Enum.at(0)
		|> Map.take(["url", "title", "id"])
		|> Enum.reduce(%{}, fn ({key, val}, acc) -> Map.put(acc, String.to_atom(key), val) end)
	end

	defp validate(%{"is_self" => true}) do
		false
	end

	defp validate(data) do
		true
	end

end
