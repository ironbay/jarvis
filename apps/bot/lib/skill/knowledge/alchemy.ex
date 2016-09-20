defmodule Bot.Skill.Alchemy do
	use Bot.Skill
	@base "https://gateway-a.watsonplatform.net/calls/url"

	def begin(bot, [api]) do
		{:ok, %{
			api: api
		}}
	end

	def on({"link.direct", %{url: url }, context}, bot, data = %{api: api}) do
		tags = url(api, "URLGetCombinedData", url)
		|> HTTPoison.get!
		|> Map.get(:body)
		|> Poison.decode!(as: %{})
		|> Map.take(["entities", "concepts"])
		|> Stream.flat_map(fn {_, x} -> x end)
		|> Stream.map(&Map.get(&1, "text"))
		|> Stream.map(&String.downcase(&1))
		|> Enum.to_list
		Bot.broadcast(bot, "link.tags", %{
			url: url,
			tags: tags
		})
		{:ok, data}
	end

	defp url(api, route, url) do
		"#{@base}/#{route}?" <> URI.encode_query(%{
			outputMode: "json",
			apikey: api,
			url: url
		})
	end
end
