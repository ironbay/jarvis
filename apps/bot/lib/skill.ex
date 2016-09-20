defmodule Bot.Skill do
	use GenServer

	defmacro __using__(_) do
		quote do
			def start_link(bot, args) do
				IO.puts("Starting #{__MODULE__}")
				GenServer.start_link(__MODULE__, [bot, args])
			end

			def init([bot, args]) do
				send(self(), {:start})
				{:ok, %{
					bot: bot,
					args: args,
					data: %{},
					pending: [],
				}}
			end

			def handle_info({:start}, state = %{bot: bot, args: args}) do
				{:ok, data} = __MODULE__.begin(bot, args)
				Bot.broadcast(bot, "skill.start", %{
					module: __MODULE__,
					args: args,
				})
				{:noreply, %{
					state |
					data: data,
				}}
			end

			def handle_cast(event = {action, body, context}, state = %{data: data, bot: bot, pending: pending}) do
				self = self()
				Task.start_link(fn ->
					try do
						{:ok, result} = __MODULE__.on(event, bot, data)
						data(self, result)
					rescue
						e in FunctionClauseError -> :ok
						e in UndefinedFunctionError -> :ok
						e -> IO.puts("Error in #{__MODULE__}: #{inspect(e)}")
					end
				end)
				pending
				|> Enum.filter(fn({compare, from, actions}) ->
					cond do
						compare == context && Enum.member?(actions, action) ->
							# send(from, {:match, event})
							false
						false ->
							true
					end
				end)
				{:noreply, %{
					state |
					pending: pending,
				}}
			end

			def data(pid, data) do
				GenServer.call(pid, {:data, data})
			end

			def handle_call({:data, next}, from, state = %{data: data}) do
				{:reply, :ok, %{
					state |
					data: Map.merge(data, next)
				}}
			end

			def terminate(reason, state) do

			end

		end
	end
end
