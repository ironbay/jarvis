defmodule Jarvis.Handler do
	use GenServer
	alias Delta.UUID
	alias Delta.Mutation
	alias Comeonin.Bcrypt

	def start_link(socket) do
		GenServer.start_link(__MODULE__, [socket])
	end

	def init([socket]) do
		IO.puts("New connection")
		Delta.watch([])
		{:ok, %{
			user: "delta-master",
			socket: socket,
		}}
	end

	def handle_connect do
		IO.puts("New connection")
		{:ok, %{
			user: "delta-master"
		}}
	end

	def handle_call({action, body}, _from, state) do
		case handle_command(action, body, state) do
			{:reply, body, state} ->
				{:reply, %{
					action: "drs.response",
					body: body,
				}, state}
			{:error, body, state} ->
				{:reply, %{
					action: "drs.error",
					body: %{
						message: body
					},
				}, state}
		end
	end

	def handle_command("delta.mutation", body, state = %{user: user}) do
		merge = Map.get(body, "$merge") || %{}
		delete = Map.get(body, "$delete") || %{}
		mutation = Mutation.new(merge, delete)
		result = Delta.mutation(mutation, user)
		{:reply, result, state}
	end

	def handle_command("delta.query", body, state = %{user: user}) do
		result = Delta.query(user, body)
		{:reply, %{
			"$merge": Map.get(result, :merge) || %{},
			"$delete": Map.get(result, :delete) || %{},
		}, state}
	end

	def handle_command("drs.ping", body, state) do
		{:reply, :os.system_time(:millisecond), state}
	end

	def handle_command(_, _, state) do
		{:error, :invalid_request, state}
	end

	def handle_info({:mutation, %{merge: merge, delete: delete}}, state = %{socket: socket}) do
		json =
			%{
				action: "delta.mutation",
				body: %{
					"$merge": merge,
					"$delete": delete
				}
			}
			|> Poison.encode!
		Socket.Web.send!(socket, {:text, json})
		{:noreply, state}
	end
end
