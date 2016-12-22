defmodule Jarvis.Link do
	use Bot.Skill
	alias Delta.Mutation
	alias Delta.Dynamic
	alias Delta.UUID

	def begin(bot, []) do
		Bot.call(bot, "regex.add", {"(?P<url>http[^\\s|\\|\\>]+)", "link.raw"})
		{:ok, %{}}
	end

	def handle_cast_async({"link.raw", %{url: url}, context}, bot, data) do
		data =
			url
			|> clean_url
			|> Map.put(:key, UUID.descending)
		Bot.cast(bot, "link.clean", data, context)
		:ok
	end

	def handle_cast_async({"link.clean", body = %{key: key}, context}, bot, data) do
		Delta.merge(["link:shares", key],
			body
			|> Map.put(:context, context)
			|> Map.put(:created, :os.system_time(:millisecond))
		)
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
		graph =
			body
			|> find_og
		%{
			url: Map.get(graph, "url") || url,
			mime: mime,
			graph: graph,
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

	def find_og(body) do
		body
		|> Floki.find(~s(meta[property]))
		|> Stream.filter(&is_og?/1)
		|> Stream.map(&pull_og/1)
		|> Enum.reduce(%{}, fn {key, value}, collect ->
			path = String.split(key, "disabled")
			value =
				case Integer.parse(value) do
					{digit, _}  -> digit
					_ -> value
				end
			Dynamic.put(collect, path, value)
		end)
	end

	def pull_og(item) do
		{
			item
			|> Floki.attribute("property")
			|> List.first
			|> String.slice(3..-1),
			item
			|> Floki.attribute("content")
			|> List.first
		}
	end

	def is_og?(item) do
		item
		|> Floki.attribute("property")
		|> List.first
		|> String.starts_with?("og")
	end

end
