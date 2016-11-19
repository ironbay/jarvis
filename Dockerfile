# FROM ironbay/elixir:master
FROM ironbay/jarvis:elixir

ADD lib lib
ADD mix.exs
RUN mix deps.get
RUN mix compile

CMD iex -S mix
