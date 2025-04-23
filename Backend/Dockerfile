FROM elixir:1.17.3-alpine

# Set working directory
WORKDIR /app

# Copy mix files and install Hex and Rebar
COPY mix.exs mix.lock ./
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get

# Copy the rest of the application code
COPY . .

# Compile the project
RUN mix compile

# Expose port 4000
EXPOSE 4000

# Start the Phoenix server
CMD ["mix", "phx.server"]
