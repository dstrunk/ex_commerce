FROM elixir:1.14

# Install hex package manager
RUN mix local.hex --force && \
    mix local.rebar --force

WORKDIR /app

COPY mix.exs mix.lock ./
RUN mix deps.get

COPY . .

RUN mix do compile

# Run migrations (uncomment if you want to run migrations automatically)
 CMD ["mix", "ecto.create", "&&", "mix", "ecto.migrate", "&&", "mix", "phx.server"]

#CMD ["mix", "phx.server"]
