defmodule Jarvis.Media.Youtube do
	use Bot.Skill
	@interval 1000 * 60 * 60
	@url "https://www.youtube.com/channel"

	def begin(bot, [key]) do
		schedule(0)
		{:ok, %{
			key: "UCWrmUNZB9-p6zgNhwNlEcyw",
		}}
	end

	defp schedule(interval) do
		Process.send_after(self(), {:poll}, interval)
	end

	def handle_info({:poll}, bot, data = %{key: key}) do
		schedule(@interval)
		"#{@url}/#{key}"
		|> HTTPoison.get!
		|> Map.get(:body)
		|> Floki.find(".yt-uix-tile-link")
		|> Floki.attribute("href")
		|> Stream.filter(&String.starts_with?(&1, "/watch"))
		|> Enum.each(&Bot.cast(bot, "link", %{url: "https://youtube.com#{&1}"}))
		:ok
	end

	def handle_cast({"link.direct", %{url: url}, context}, bot, data) do
		if String.starts_with?(url, "https://www.youtube.com") do
			Bot.cast(bot, "video", %{type: "youtube", url: url}, context)
		end
		:ok
	end
end
