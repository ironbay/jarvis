FROM ironbay/elixir:master
# FROM ironbay/jarvis:elixir

ADD . .
RUN mix deps.get
RUN mix compile

CMD iex --cookie server --name jarvis@100.33.127.192 -S mix
