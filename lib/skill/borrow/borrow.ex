defmodule Jarvis.Borrow do
	use Bot.Skill
	alias Delta.Dynamic

	@interval 1000 * 10
	@template "Hey <%= author %>

I'm interested in lending the <%= request %> you asked for.  I'm only looking for 15% interest which is <%= request * 1.15 %> in payback - less than most lenders here.  Can you reply with the following?

- Your PayPal information
- Your phone number
- Your email
- Date you will repay

Once I get this I'll go ahead and send you the money
Thanks!
"

	def begin(bot, []) do
		Bot.cast(bot, "regex.add", {"^borrow history (?P<author>.+)", "borrow.history.request"})
		Bot.cast(bot, "locale.add", {"borrow.loan", ">>>
Author: <%= author %>
Request: <%= request %>
<%= title %>
<%= paid.count %> paid loans totalling $<%= paid.value %>
<%= unpaid.count %> unpaid loans totalling $<%= unpaid.value %>
<%= pending.count %> pending loans totalling $<%= pending.value %>
https://www.reddit.com/r/borrow/comments/<%= key %>
"})
		Bot.cast(bot, "locale.add", {"borrow.history", ">>>
<%= paid.count %> paid loans totalling $<%= paid.value %>
<%= unpaid.count %> unpaid loans totalling $<%= unpaid.value %>
<%= pending.count %> pending loans totalling $<%= pending.value %>
"})
		schedule(@interval)
		{:ok, %{
			last: 0 |> fetch_since |> get_last || 0
		}}
	end

	defp schedule(interval) do
		Process.send_after(self, :poll, interval)
	end

	def handle_info(:poll, bot, data) do
		next = poll(bot, data.last)
		schedule(@interval)
		{:ok, Map.put(data, :last, next)}
	end

	def handle_cast({"borrow.history.request", body, context}, bot, data) do
		Bot.cast(bot, "borrow.history", fetch_history(body), context)
		:ok
	end

	defp poll(bot, last) do
		requests = fetch_since(last)

		if last !== 0 do
			requests
			|> Enum.each(&Bot.cast(bot, "borrow.loan", &1,  %{
				channel: "G3T1J0QJK",
				team: "strange-loop",
				type: "slack"
			}))

			requests
			|> Enum.each(&save/1)

			requests
			|> Enum.each(&send_pm/1)

		end

		requests
		|> get_last || last
	end

	defp save(data) do
		Delta.merge(["loan:info", data.key], data)
	end

	def send_pm(data) do
		formatted =
			@template
			|> EEx.eval_string(Enum.into(data, []))
		Delta.merge(["loan:info", data.key, "pm"], true)
		if data.unpaid.count == 0 && data.pending.count == 0 && data.paid.count > 0 && data.request >= 150 do
			Task.start fn ->
				:timer.sleep(1000 * 60)
				Reddit.send(data.author, "Loan Request", formatted)
			end
		end
	end

	defp fetch_since(since) do
		"https://www.reddit.com/r/borrow/new.json"
		|> HTTPoison.get!
		|> Map.get(:body)
		|> Poison.decode!
		|> Dynamic.get(["data", "children"])
		|> Dynamic.default(%{})
		|> Stream.map(fn %{"data" => value}->
			%{
				key: Map.get(value, "id"),
				title: Map.get(value, "title"),
				description: Map.get(value, "selftext"),
				time: Map.get(value, "created_utc"),
				status: Map.get(value, "link_flair_text"),
				author: Map.get(value, "author"),
			}
		end)
		|> Stream.map(&parse/1)
		|> Stream.filter(fn %{time: time} -> time > since end)
		|> Stream.filter(fn %{title: title} -> valid_title?(title) end)
		|> Stream.filter(fn %{status: status} -> status !== "Completed" end)
		|> Enum.to_list
	end

	defp valid_title?(title) do
		lower = title |> String.downcase
		String.contains?(lower, "[req]") && !String.contains?(lower, "arranged")
	end

	defp get_last(requests) do
		case List.first(requests) do
			nil -> nil
			%{time: time} -> time
		end
	end

	defp parse(input) do
		input
		|> Map.merge(parse_amount(input))
		|> Map.merge(fetch_history(input))
	end

	defp fetch_history(%{author: author}) do
		"https://redditloans.com/api/loans.php?format=3&limit=100&borrower_name=#{author}&include_deleted=0"
		|> HTTPoison.get!
		|> Map.get(:body)
		|> Poison.decode!
		|> Map.get("loans")
		|> Enum.reduce(%{
			paid: %{
				count: 0,
				value: 0,
			},
			pending: %{
				count: 0,
				value: 0,
			},
			unpaid: %{
				count: 0,
				value: 0,
			}
		}, fn  %{ "principal_cents" => lent, "principal_repayment_cents" => paid, "unpaid" => unpaid }, collect ->
			type =
				cond do
					unpaid == 1 -> :unpaid
					lent == paid -> :paid
					true -> :pending
				end
			count = Dynamic.get(collect, [type, :count])
			value = Dynamic.get(collect, [type, :value])
			collect
			|> Dynamic.put([type, :count], count + 1)
			|> Dynamic.put([type, :value], value + lent / 100)
		end)

	end

	defp parse_amount(input = %{title: title}) do
		match =
			~r/\([^\d]*(\d+)[^\d]*\)/
			|> Regex.run(title)
			|> Dynamic.default([])
			|> List.last
			|> Dynamic.default("0")
			|> Integer.parse
		request =
			case match do
				:error -> 0
				{parsed, _} -> parsed
			end
		%{
			request: request
		}
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
