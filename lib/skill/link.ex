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

	def handle_cast_async({"link.clean", body = %{url: url}, context}, bot, data) do
		key = UUID.descending()
		hierarchy = Bot.call(bot, "context.path", context)
		case Delta.query_path(["link:info", url]) === %{} do
			true ->
				mutation =
					Mutation.new
					|> Mutation.merge(["link:info", url], body)
				{_, mutation} =
					hierarchy
					|> Enum.reduce({[], mutation}, fn item, {path, mutation} ->
						path = path ++ [item]
						{
							path,
							mutation
							|> Mutation.merge(["context:links", Enum.join(path, ":"), key], %{
								key: key,
								url: url,
								created: :os.system_time(:millisecond),
								context: context,
							})
						}
					end)
				Delta.mutation(mutation)
			_ ->
				Bot.cast(bot, "bot.message", "You're ruining everything with your reposts", context)
		end
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
			|> pull_meta("og", "property")
		twitter =
			body
			|> pull_meta("twitter", "name")
			|> Map.merge(pull_meta(body, "twitter", "property"))
		%{
			url: Map.get(graph, "url") || url,
			mime: mime,
			graph: graph,
			twitter: twitter,
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

	def pull_meta(body, prefix, key) do
		body
		|> Floki.find(~s(meta[#{key}]))
		|> Stream.filter(&is_prefix?(&1, prefix, key))
		|> Stream.map(&pull_property(&1, prefix, key))
		|> Enum.reduce(%{}, fn {key, value}, collect ->
			path = String.split(key, "disabled")
			value =
				case Integer.parse(value) do
					{digit, ""}  -> digit
					_ -> value
				end
			Dynamic.put(collect, path, value)
		end)
	end

	def pull_property(item, prefix, key) do
		length = String.length(prefix) + 1
		{
			item
			|> Floki.attribute(key)
			|> List.first
			|> String.slice(length..-1),
			item
			|> Floki.attribute("content")
			|> List.first
		}
	end

	def is_prefix?(item, prefix, key) do
		item
		|> Floki.attribute(key)
		|> List.first
		|> String.starts_with?(prefix)
	end

end
