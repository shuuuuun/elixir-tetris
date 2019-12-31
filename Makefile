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

# .PHONY: iex
# iex:
# 	docker run -it --rm -v ${PWD}:/app -w /app elixir
