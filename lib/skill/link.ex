defmodule Jarvis.Link do
	use Bot.Skill
	alias Delta.Mutation
	alias Delta.UUID

	def begin(bot, []) do
		Bot.call(bot, "regex.add", {"(?P<url>http[^\\s|\\|\\>]+)", "link.raw"})
		{:ok, %{}}
	end

	def handle_cast_async({"link.raw", %{url: url}, context}, bot, data) do
		data = url |> clean_url
		Bot.cast(bot, "link.clean", data, context)
		:ok
	end

	def handle_cast_async({"link.clean", %{url: url, mime: mime}, context}, bot, data) do
		key = UUID.ascending()
		Delta.merge(["link:shares", key], %{
			key: key,
			url: url,
			mime: mime,
			context: context,
		})
		:ok
	end

	defp clean_url(url) do
		%{
			body: body,
			headers: headers,
		} = HTTPoison.request!(:get, url, "", [], [hackney: [{:follow_redirect, true}]])

		mime =
			headers
			|> get_mime
			|> clean_mime
		url = find_url(body) || url
		%{
			url: url,
			mime: mime,
		}
	end

	def get_mime(headers) do
		case Enum.find(headers, nil, fn {header, _} -> header == "Content-Type" end) do
			nil -> nil
			{_, type} -> type
		end
	end

	def clean_mime(type) do
		case type do
			nil -> nil
			type ->
				type
				|> String.split(";")
				|> List.first
		end
	end

	def find_url(body) do
		body
		|> Floki.find(~s([property="og:url"]))
		|> Floki.attribute("content")
		|> Enum.at(0)
	end

end
