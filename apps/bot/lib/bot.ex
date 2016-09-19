defmodule Bot.Supervisor do
	use Supervisor
	@name :bot_supervisor

	def start_link do
		Supervisor.start_link(__MODULE__, [], name: @name)
	end

	def init(_) do
		IO.puts("Starting #{__MODULE__}")
		:syn.init()
		children = [
			worker(Bot, [], restart: :transient),
		]
		supervise(children, strategy: :simple_one_for_one)
	end

	def start_child(key) do
		Supervisor.start_child(@name, [key])
	end
end

defmodule Bot do
	use GenServer

	def start_link(key) do
		GenServer.start_link(__MODULE__, [key], name: via_tuple(key))
	end

	def init([key]) do
		IO.puts("Starting Bot #{key}")
		{:ok, skills} = Bot.Skill.Supervisor.start_link

		# TODO: Load from config
		Bot.Skill.Supervisor.enable_skill(skills, Bot.Skill.Regex, [])
		Bot.Skill.Supervisor.enable_skill(skills, Bot.Skill.Controller, [])
		Bot.Skill.Supervisor.enable_skill(skills, Bot.Skill.Locale, [])
		Bot.Skill.Supervisor.enable_skill(skills, Bot.Skill.Link, [])

		Bot.Skill.Supervisor.enable_skill(skills, Bot.Skill.Greeter, [])
		Bot.Skill.Supervisor.enable_skill(skills, Bot.Skill.Name, [])

		Bot.Skill.Supervisor.enable_skill(skills, Bot.Skill.Slack, ["xoxb-41877287558-bhzZMosiGo6cwr2its3UXsAD", ""])
		Bot.Skill.Supervisor.enable_skill(skills, Bot.Skill.Slack, ["xoxb-31798286241-A1mDAuVSWN39vrfphUg8Bmf6", "C07FCH70A"])

		Bot.Skill.Supervisor.enable_skill(skills, Bot.Skill.Reddit.Link, [])
		Bot.Skill.Supervisor.enable_skill(skills, Bot.Skill.Reddit.Poller, ["aww"])
		Bot.Skill.Supervisor.enable_skill(skills, Bot.Skill.Reddit.Poller, ["politics"])
		Bot.Skill.Supervisor.enable_skill(skills, Bot.Skill.Reddit.Poller, ["news"])

		{:ok, %{
			key: key,
			pending: [],
			skills: skills,
		}}
	end

	defp via_tuple(key) do
		{:via, :syn, {Bot, key}}
	end

	def broadcast(pid, action, body, context \\ %{}) do
		GenServer.call(pid, {:broadcast, {action, body, context}})
	end

	def handle_call({:broadcast, {action, body, context}}, _from, state = %{skills: skills, pending: pending}) do
		event = {action, body, context}
		IO.puts("Broadcasting #{inspect(event)}")

		# Notify waiting dialogues
		next = pending
		|> Enum.filter(fn({compare, from, actions}) ->
			cond do
				compare == context && Enum.member?(actions, action) ->
					send(from, {:match, event})
					false
				true ->
					true
			end
		end)

		Bot.Skill.Supervisor.notify(skills, event)
		{:reply, :ok, %{
			state |
			pending: next,
		}}
	end

	def enable_skill(pid, module, args) do
		GenServer.call(pid, {:enable_skill, module, args})
	end

	def handle_call({:enable_skill, module, args}, _from, state = %{skills: skills}) do
		IO.puts("Enabling #{module}")
		Bot.Skill.Supervisor.enable_skill(skills, module, args)
		{:reply, :ok, state}
	end

	def wait(pid, context, actions) do
		GenServer.call(pid, {:wait, context, actions})
		receive do
			{:match, event} -> event
		end
	end

	def handle_call({:wait, context, actions}, {from, _ref}, state = %{pending: pending}) do
		next = pending
		|> clear(context)
		|> List.insert_at(0, {context, from, actions})
		{:reply, :ok, %{
			state |
			pending: next,
		}}
	end

	def clear(pending, context) do
		pending
		|> Enum.filter(fn({compare, from, _}) ->
			case compare do
				^context ->
					Process.exit(from, :normal)
					false
				_ -> true
			end
		end)
	end

end

defmodule Bot.Skill.Supervisor do
	use Supervisor

	def start_link() do
		Supervisor.start_link(__MODULE__, [self()])
	end

	def init([bot]) do
		children = [
		]
		supervise(children, strategy: :one_for_one)
	end

	defp skill(bot, module, args) do
		worker(module, [bot, args])
	end

	def enable_skill(sup, module, args) do
		Supervisor.start_child(sup, worker(module, [self(), args], id: {module, args}))
	end

	def notify(pid, event) do
		Supervisor.which_children(pid)
		|> Enum.each(fn({_, x, _, _}) ->
			GenServer.cast(x, event)
		end)
	end

end
