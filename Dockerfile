FROM ironbay/elixir:master

ADD . .
RUN mix deps.get
RUN mix compile

CMD iex -S mix
