defmodule Bot.Skill.Link do
	use Bot.Skill

	def begin(bot, args) do
		Bot.broadcast(bot, "regex.add", {"(?P<url>http[^\\s|\\|\\>]+)", "link"})
		{:ok, %{}}
	end

	def on({"link", %{url: url}, context}, bot, data) do
		real = HTTPoison.request!(:get, url, "", [], [hackney: [{:follow_redirect, true}]])
		|> Map.get(:body)
		|> Floki.find(~s([property="og:url"]))
		|> Floki.attribute("content")
		|> IO.inspect
		|> Enum.at(0)
		Bot.broadcast(bot, "link.direct", %{
			url: real,
		}, context)
		{:ok, data}
	end
	
	def on({"link", %{url: url}, context}, bot, data) do
		real = HTTPoison.request!(:get, url, "", [], [hackney: [{:follow_redirect, true}]])
		|> Map.get(:body)
		|> Floki.find(~s([property="og:url"]))
		|> Floki.attribute("content")
		|> IO.inspect
		|> Enum.at(0)
		Bot.broadcast(bot, "link.direct", %{
			url: real,
		}, context)
		{:ok, data}
	end
end
