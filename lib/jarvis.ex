defmodule Jarvis do
	use Application
#
	# See http://elixir-lang.org/docs/stable/elixir/Application.html
	# for more information on OTP Applications
	def start(_type, _args) do
		import Supervisor.Spec, warn: false
		:syn.init
		# Define workers and child supervisors to be supervised
		children = [
			# Starts a worker by calling: Bot.Worker.start_link(arg1, arg2, arg3)
			worker(Jarvis.Proxy, []),
			worker(Jarvis.Rest, []),
		]


		# See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
		# for other strategies and supported options
		opts = [strategy: :one_for_one, name: Jarvis]
		Supervisor.start_link(children, opts)
	end
end

defmodule Jarvis.Proxy do
	use GenServer

	def start_link do
		GenServer.start_link(__MODULE__, [])
	end

	def init(_) do
		{:ok, bot} = Bot.start_link(:jarvis_bot)
		config
		|> Map.get(:skills)
		|> Enum.each(fn %{module: module, args: args} ->
			Bot.enable_skill(bot, String.to_existing_atom("Elixir." <> module), args)
		end)

		{:ok, []}
	end

	defp config() do
		Application.get_env(:jarvis, :config)
		|> File.read!
		|> Poison.decode!(keys: :atoms)
	end
end
