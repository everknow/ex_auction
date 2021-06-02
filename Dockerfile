FROM elixir:1.11.4-alpine

RUN mix local.hex --force
RUN mix local.rebar --force

# Building arguments
ARG GOOGLE_CLIENT_ID
ARG DATABASE_NAME
ARG DATABASE_USER
ARG DATABASE_PASSWORD
ARG DATABASE_HOSTNAME
ARG DATABASE_PORT

COPY . /app
WORKDIR /app




RUN MIX_ENV=prod mix release ex_auctions