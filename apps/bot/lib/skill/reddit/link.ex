defmodule Bot.Skill.Reddit.Link do
	use Bot.Skill

	@base "https://www.reddit.com"

	def begin(bot, args) do
		{:ok, %{}}
	end

	def on({"link", %{url: url}, context}, bot, data) do
		request = "#{@base}/submit.json?#{URI.encode_query([{:url, url}])}"
		response =
		# Search reddit for url
		HTTPoison.request!(:get, request, "", [], [hackney: [{:follow_redirect, true}]])
		|> Map.get(:body)
		|> Poison.decode!(as: %{})
		|> Kernel.get_in(["data", "children"])
		|> Enum.at(0)
		|> Kernel.get_in(["data", "permalink"])
		|> comment_url
		# Fetch comments
		|> HTTPoison.get!
		|> Map.get(:body)
		|> Poison.decode!(as: [])
		|> Enum.at(1)
		|> Kernel.get_in(["data", "children"])
		# Fetch comment text
		|> Stream.map(&Kernel.get_in(&1, ["data", "body"]))
		# Filter out deleted comments
		|> Stream.filter(&validate(&1))
		|> Stream.take(1)
		|> Enum.at(0)
		Bot.broadcast(bot, "chat.response", response, context)
		{:ok, data}
	end

	defp comment_url(permalink) do
		"#{@base}#{permalink}comments.json"
	end

	defp validate("[removed]") do
		false
	end

	defp validate(comment) do
		true
	end

	defp print(thing) do
		IO.inspect(thing)
		thing
	end

end
