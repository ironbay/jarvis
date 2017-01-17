defmodule Jarvis.Borrow do
	use Bot.Skill
	alias Delta.Dynamic

	@interval 1000 * 30

	def begin(bot, []) do
		Bot.cast(bot, "locale.add", {"borrow.loan", ">>> Request: <%= request %>\nReturn: <%= return || \"Unknown\" %>\nhttps://www.reddit.com/r/borrow/comments/<%= id %>"})
		schedule(0)
		{:ok, %{
			last: 0
		}}
	end

	defp schedule(interval) do
		Process.send_after(self, :poll, interval)
	end

	def handle_info(:poll, bot, data) do
		requests =
			HTTPoison.get!("https://www.reddit.com/r/borrow/new.json")
			|> Map.get(:body)
			|> Poison.decode!
			|> Dynamic.get(["data", "children"])
			|> Dynamic.default(%{})
			|> Stream.map(fn %{"data" => value}->
				%{
					id: Map.get(value, "id"),
					title: Map.get(value, "title"),
					time: Map.get(value, "created_utc"),
				}
			end)
			|> Stream.filter(fn %{time: time} -> time > data.last end)
			|> Stream.filter(fn %{title: title} -> String.starts_with?(title, "[REQ]") end)
			|> Stream.map(&parse/1)
			|> Stream.filter(&(Map.get(&1, :request) !== nil))
			|> Enum.to_list

		requests
		|> Enum.each(&Bot.cast(bot, "borrow.loan", &1,  %{
			channel: "G3T1J0QJK",
			sender: "U0SFBTD3Q",
			team: "strange-loop",
			type: "slack"
		}))
		{:ok, Map.put(data, :last, requests |> List.first |> Map.get(:time))}
	end

	defp parse(input) do
		input
		|> Map.merge(parse_amount(input))
	end

	defp parse_amount(input = %{title: title}) do
		case parse_amount(title) do
			[request, return] -> %{
				request: request,
				return: return,
			}
			[request] -> %{
				request: request,
				return: nil,
			}
			_ -> %{}
		end
	end

	defp parse_amount(title) do
		~r/\$(\d+)/
		|> Regex.scan(title)
		|> Stream.map(&Enum.at(&1, 1))
		|> Stream.map(&Integer.parse/1)
		|> Enum.map(&Tuple.to_list/1)
		|> Stream.map(&Enum.at(&1, 0))
		|> Enum.to_list
	end
end
