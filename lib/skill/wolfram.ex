defmodule Jarvis.Wolfram do
	use Bot.Skill

	@base "http://api.wolframalpha.com/v2/query?"
	def begin(bot, [key]) do
		Bot.cast(bot, "regex.add", {"(?P<query>.+)\\?$", "wolfram.search"})
		{:ok, %{
			url: "#{@base}appid=#{key}&input="
		}}
	end

	def on({"wolfram.search", %{query: query }, context}, bot, data = %{url: url}) do
		import SweetXml
		response = "#{url}#{URI.encode(query)}"
		|> HTTPoison.get!
		|> Map.get(:body)
		|> xpath(~x"//pod[@title=\"Result\"]/subpod/plaintext/text()")
		|> String.Chars.to_string
		if response != "" do
			Bot.cast(bot, "chat.response", response, context)
		end
		{:ok, data}
	end
end
