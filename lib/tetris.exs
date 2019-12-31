# $ mix run lib/tetris.ex

# TODO: next表示
# TODO: hold機能

defmodule Tetris do
  @moduledoc """
  Documentation for Tetris.
  """
  @behaviour Ratatouille.App

  alias Ratatouille.Runtime.Subscription
  alias Tetris.Block

  import Ratatouille.Constants, only: [key: 1]
  import Ratatouille.View

  @debug Mix.env() != :prod

  @space key(:space)
  @up key(:arrow_up)
  @down key(:arrow_down)
  @left key(:arrow_left)
  @right key(:arrow_right)
  @arrows [@up, @down, @left, @right]

  @cols 12
  @rows 12
  @number_of_stone 4
  @hidden_rows @number_of_stone
  @logical_rows @rows + @hidden_rows

  def init(_context) do
    %{
      board: empty_board(),
      current_block: generate_block(),
      next_block: generate_block(),
      alive: true,
      score: 0,
      # height: window.height - 2,
      # width: window.width - 2
      # height: @rows,
      # width: @cols
    }
  end

  def update(model, msg) do
    # TODO: key押してるときtickが進まない問題
    # IO.puts inspect(msg)
    # model = if msg == :tick, do: tick(model), else: model
    # model =
    #   case msg do
    #     :tick -> tick(model)
    #     _ -> model
    #   end
    case msg do
      # :tick -> tick(model)
      {:event, %{key: key}} when key in @arrows -> %{model | current_block: move_block(key, model)}
      {:event, %{key: key}} when key == @space -> init(model)
      :tick -> tick(model)
      _ -> model
    end
  end

  def subscribe(_model) do
    Subscription.interval(1000, :tick)
    # Subscription.batch([
    #   Subscription.interval(1000, :tick)
    # ])
  end

  def render(model) do
    view do
      panel(
        title: "Elixir Tetris",
        height: :fill,
      ) do
        render_board(model)
        label(content: "Score: #{model.score}", wrap: true)
        # if @debug, do: label(content: "Debug Log:\n#{inspect(model.log)}", wrap: true)
        if @debug, do: label(content: "Model:\n#{inspect(model)}", wrap: true)
      end
    end
  end

  defp render_board(%{alive: false}) do
    label(content: "Game Over")
  end

  defp render_board(model) do
    # TODO: もうちょい見やすくしたい
    %{ board: board } = freeze(model)
    board = Enum.drop(board, @hidden_rows)
    # board_cells = for {row, y} <- Enum.with_index(board), {val, x} <- Enum.with_index(row) do
    #   color = if val > 0, do: :white, else: :black
    #   # canvas_cell(x: x, y: y, char: "■", color: color)
    #   # canvas_cell(x: x, y: y, char: "■", color: color, background: color)
    #   canvas_cell(x: x, y: y, char: "_", color: color, background: color)
    # end

    # canvas(height: @cols, width: @rows) do
    # canvas(height: model.height, width: model.width) do
    #   board_cells
    # end
      table do
        for row <- board do
          table_row do
            for val <- row do
              # colors: default, black, red, green, yellow, blue, magenta, cyan, white
              # color = if val > 0, do: :white, else: :black
              # color = if val > 0, do: :black, else: :white
              color = if val > 0, do: :blue, else: :white
              # table_cell(content: "_", color: color, background: color)
              table_cell(content: "", background: color)
            end
          end
        end
      end
  end

  defp tick(model) do
    { is_valid, new_block } = move_block_down(model)
    cond do
      not is_valid ->
        %{model |> freeze() |> clear_lines() |> check_game_over() | current_block: model.next_block, next_block: generate_block()}

      is_valid ->
        %{model | current_block: new_block}

      true ->
        model
    end
  end

  defp generate_block() do
    # Block.random(@cols / 2, 0)
    Block.random(0, 0)
  end

  defp move_block(@left, model) do
    { is_valid, new_block } = move_block_left(model)
    if is_valid, do: new_block, else: model.current_block
  end
  defp move_block(@right, model) do
    { is_valid, new_block } = move_block_right(model)
    if is_valid, do: new_block, else: model.current_block
  end
  defp move_block(@down, model) do
    { is_valid, new_block } = move_block_down(model)
    if is_valid, do: new_block, else: model.current_block
  end
  defp move_block(@up, model) do
    { is_valid, new_block } = rotate_block(model)
    if is_valid, do: new_block, else: model.current_block
  end

  defp move_block_left(%{ board: board, current_block: current_block }) do
    new_block = Block.move_left(current_block)
    is_valid = validate(board, new_block)
    { is_valid, new_block }
  end

  defp move_block_right(%{ board: board, current_block: current_block }) do
    new_block = Block.move_right(current_block)
    is_valid = validate(board, new_block)
    { is_valid, new_block }
  end

  defp move_block_down(%{ board: board, current_block: current_block }) do
    new_block = Block.move_down(current_block)
    is_valid = validate(board, new_block)
    { is_valid, new_block }
  end

  defp rotate_block(%{ board: board, current_block: current_block }) do
    new_block = Block.rotate(current_block)
    is_valid = validate(board, new_block)
    { is_valid, new_block }
  end

  defp validate(board, block, offset_x \\ 0, offset_y \\ 0) do
    next_x = block.x + offset_x
    next_y = block.y + offset_y

    Enum.with_index(block.shape) |> Enum.all?(fn {row, y} ->
      Enum.with_index(row) |> Enum.all?(fn {val, x} ->
        board_x = x + next_x
        board_y = y + next_y
        board_row = Enum.at(board, board_y, [])
        board_val = Enum.at(board_row, board_x, -1)
        # IO.inspect {board_x, board_y, board_val}
        is_outside_left_wall = board_x < 0
        is_outside_right_wall = board_x > @cols
        is_under_bottom = board_y > @logical_rows
        is_outside_board = board_y >= length(board) or board_x >= length(board_row)
        is_exists_block = board_val > 0
        # IO.inspect {is_outside_left_wall, is_outside_right_wall, is_under_bottom, is_outside_board, is_exists_block}
        val <= 0 or not (is_outside_left_wall or is_outside_right_wall or is_under_bottom or is_outside_board or is_exists_block)
      end)
    end)
  end

  defp freeze(%{ board: board, current_block: block } = model) do
    # for y <- 0..@number_of_stone-1, x <- 0..@number_of_stone-1 do
    #   board_x = x + block.x
    #   board_y = y + block.y
    #   # val = if block.shape[y][x], do: block.block_id + 1, else: 0
    #   shape_val = block.shape |> Enum.at(y, []) |> Enum.at(x)
    #   # new_val = if shape_val, do: block.block_id + 1, else: 0
    #   new_val = if shape_val, do: 1, else: 0
    #   # List.update_at(board, board_y, fn row -> List.insert_at(row, board_x, new_val) end)
    #   board = List.update_at(board, board_y, fn row -> List.replace_at(row, board_x, new_val) end)
    # end
    # board
    # for {row, board_y} <- Enum.with_index(board), {val, board_x} <- Enum.with_index(row) do
    #   x = board_x - block.x
    #   y = board_y - block.y
    #   shape_val = block.shape |> Enum.at(y, []) |> Enum.at(x, 0)
    #   # IO.inspect shape_val
    #   shape_val
    # end
    new_board =
      Enum.with_index(board) |> Enum.map(fn {row, board_y} ->
        Enum.with_index(row) |> Enum.map(fn {val, board_x} ->
          x = board_x - block.x
          y = board_y - block.y
          shape_val = block.shape |> Enum.at(y, []) |> Enum.at(x, -1)
          cond do
            x < 0 or y < 0 -> val
            shape_val > 0 -> shape_val
            true -> val
          end
        end)
      end)
    %{ model | board: new_board }
  end

  defp clear_lines(%{ board: board, score: score } = model) do
    # TODO: 1行消去で速度を上げる

    cleared_board =
      Enum.reject(board, fn row ->
        Enum.all?(row, fn val -> val > 0 end)
      end)
    clear_count = Enum.count(board) - Enum.count(cleared_board)
    new_board = Enum.slice(empty_board() ++ cleared_board, -@logical_rows..-1)
    new_score = score + clear_count

    %{ model | board: new_board, score: new_score }
  end

  defp check_game_over(%{ current_block: block } = model) do
    # ブロックの全てが画面外ならゲームオーバー
    is_game_over =
      Enum.with_index(block.shape) |> Enum.all?(fn {row, y} ->
        Enum.with_index(row) |> Enum.all?(fn {val, _x} ->
          board_y = y + block.y
          val == 0 or board_y < @hidden_rows
        end)
      end)
    %{ model | alive: !is_game_over }
  end

  defp empty_board() do
    Enum.map(1..@logical_rows, fn _ -> Enum.map(1..@cols, fn _ -> 0 end) end)
  end
end

# Ratatouille.run(Tetris, interval: 1000)
# Ratatouille.run(Tetris, interval: 100)
Ratatouille.run(Tetris)
