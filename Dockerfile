FROM ironbay/elixir:master
# FROM ironbay/jarvis:elixir

RUN pacman --noconfirm -S gcc
RUN pacman --noconfirm -S libuv
RUN pacman --noconfirm -S cmake

WORKDIR /tmp
ADD mix.exs mix.exs
ADD mix.lock mix.lock
ADD config config
RUN mix deps.get
RUN mix deps.compile

WORKDIR /app
ADD . .
RUN cp -a /tmp/deps .
RUN cp -a /tmp/_build .
RUN ls -lah
RUN mix deps.get
RUN mix compile


CMD iex -S mix
