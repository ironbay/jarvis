defmodule Jarvis.Plugin do
	defmacro __using__(_opts) do
		quote do
			def handle_connect(_socket) do
				Delta.watch([])
				{:ok, %{
					user: "delta-master"
				}}
			end
		end
	end
end
