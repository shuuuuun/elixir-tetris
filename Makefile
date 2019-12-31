.PHONY: run
run:
	MIX_ENV=prod mix run lib/tetris.exs

.PHONY: run-dev
run-dev:
	MIX_ENV=dev mix run lib/tetris.exs
# mix run -e 'Ratatouille.run(Tetris)'

.PHONY: get
get:
	mix deps.get

.PHONY: test
test:
	MIX_ENV=test mix test

.PHONY: console
console:
	iex -S mix

.PHONY: docker-iex
docker-iex:
	docker run -it --rm -v ${PWD}:/app --workdir /app elixir:slim

# .PHONY: docker-console
# docker-console:
# 	docker run -it --rm -v ${PWD}:/app --workdir /app elixir:slim iex -S mix

# .PHONY: docker-get
# docker-get:
# 	docker run -it --rm -v ${PWD}:/app --workdir /app elixir:slim mix deps.get

# .PHONY: docker-run
# docker-run:
# 	docker run -it --rm -v ${PWD}:/app --workdir /app --env MIX_ENV=prod elixir:slim mix run lib/tetris.exs
