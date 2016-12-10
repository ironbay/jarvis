# FROM ironbay/elixir:master
FROM ironbay/jarvis:elixir

ADD lib lib
ADD config config
ADD mix.exs mix.exs
ADD mix.lock mix.lock
RUN mix deps.get
RUN mix compile

CMD iex --cookie server --name jarvis@100.33.127.192 -S mix
