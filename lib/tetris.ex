# $ mix run lib/tetris.ex

defmodule Tetris do
  @moduledoc """
  Documentation for Tetris.
  """
  @behaviour Ratatouille.App

  alias Ratatouille.Runtime.Subscription

  import Ratatouille.Constants, only: [key: 1]
  import Ratatouille.View

  @up key(:arrow_up)
  @down key(:arrow_down)
  @left key(:arrow_left)
  @right key(:arrow_right)
  @arrows [@up, @down, @left, @right]

  # @initial_length 4

  @cols 6
  @rows 12
  @number_of_stone 4
  @hidden_rows @number_of_stone
  @logical_rows @rows + @hidden_rows

  # var clear_effect: (StonePair) -> Promise<Void> = {_ in Promise()}
  # var calc_score: (StonePair) -> Int = {_ in 0}
  # var score: Int = 0
  # var on_game_over: () -> Void = {}
  # var board: [[Stone?]]
  # var current_block: Block!
  # var next_block: Block!
  # var is_playng: Bool = false
  # var is_game_over: Bool = false
  # var is_effecting: Bool = false

  def init(%{window: window}) do
    # IO.puts "window.height: #{window.height}"
    # IO.puts "window.width: #{window.width}"
    %{
      # board: Array(repeating: Array(repeating: nil, count: self.cols), count: self.logicalRows),
      board: Enum.map(1..@rows, fn _ -> Enum.map(1..@cols, fn _ -> 0 end) end),
      current_block: generate_block(),
      next_block: generate_block(),
      direction: :right,
      # chain: for(x <- @initial_length..1, do: {x, 0}),
      # food: {7, 7},
      alive: true,
      height: window.height - 2,
      width: window.width - 2
      # height: @rows,
      # width: @cols
    }
  end

  def update(model, msg) do
    case msg do
      # {:event, %{key: key}} when key in @arrows -> %{model | direction: next_dir(model.direction, key_to_dir(key))}
      {:event, %{key: key}} when key in @arrows -> %{model | current_block: move_block(key, model)}
      :tick -> tick(model)
      _ -> model
    end
  end

  def subscribe(_model) do
    Subscription.interval(1000, :tick)
  end

  def render(model) do
    # score = length(chain) - 4
    score = 0

    view do
      panel(
        title: "Tetris Score=#{score}, Model=#{inspect(model)}",
        height: :fill,
        # height: @rows,
        padding: 0
      ) do
        render_board(model)
      end
    end
  end

  defp render_board(%{alive: false}) do
    label(content: "Game Over")
  end

  defp render_board(model) do
    # shape = Enum.at(@shape_list, 0)
    # shape = Enum.random(@shape_list)
    %{ shape: block_shape, x: block_x, y: block_y } = model.current_block
    block_cells = for {row, y} <- Enum.with_index(block_shape), {val, x} <- Enum.with_index(row), do: canvas_cell(x: x + block_x, y: y + block_y, char: Integer.to_string(val))
    board_cells = for {row, y} <- Enum.with_index(model.board), {val, x} <- Enum.with_index(row), do: canvas_cell(x: x, y: y, char: Integer.to_string(val))

    # canvas(height: @cols, width: @rows) do
    canvas(height: model.height, width: model.width) do
      board_cells ++ block_cells
    end
  end

  defp tick(model) do
    # [head | tail] = model.chain
    # next = next_link(head, model.direction)
    # next = head

    { is_valid, new_block } = move_block_down(model)
    # IO.puts is_valid
    cond do
    # if not move_block_down():
    #     freeze()
    #     clear_lines()
    #     if check_game_over():
    #         quit_game()
    #         return False
    #     frame_count += 1
    #     create_current_block()
    #     create_next_block()

      # not next_valid?(next, model) ->
      #   %{model | alive: false}

      # next == model.food ->
      #   new_food = random_food(model.width - 1, model.height - 1)
      #   %{model | chain: [next, head | tail], food: new_food}

      not is_valid ->
        %{model | current_block: model.next_block, next_block: generate_block()}

      is_valid ->
        %{model | current_block: new_block}

      true ->
        model
    end
  end

  # defp random_food(max_x, max_y) do
  #   {Enum.random(0..max_x), Enum.random(0..max_y)}
  # end

  defp key_to_dir(@up), do: :up
  defp key_to_dir(@down), do: :down
  defp key_to_dir(@left), do: :left
  defp key_to_dir(@right), do: :right

  defp next_valid?({x, y}, _model) when x < 0 or y < 0, do: false
  defp next_valid?({x, _y}, %{width: width}) when x >= width, do: false
  defp next_valid?({_x, y}, %{height: height}) when y >= height, do: false
  defp next_valid?(next, %{chain: chain}), do: next not in chain

  defp next_dir(:up, :down), do: :up
  defp next_dir(:down, :up), do: :down
  defp next_dir(:left, :right), do: :left
  defp next_dir(:right, :left), do: :right
  defp next_dir(_current, new), do: new

  defp next_link({x, y}, _), do: {x, y}
  defp next_link({x, y}, :up), do: {x, y - 1}
  defp next_link({x, y}, :down), do: {x, y + 1}
  defp next_link({x, y}, :left), do: {x - 1, y}
  defp next_link({x, y}, :right), do: {x + 1, y}

  defp generate_block() do
    # Block.new(0, @cols / 2, 0)
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

  defp move_block_left(model) do
    new_block = Block.move_left(model.current_block)
    is_valid = validate(model, -1, 0, new_block)
    { is_valid, new_block }
  end

  defp move_block_right(model) do
    new_block = Block.move_right(model.current_block)
    is_valid = validate(model, 1, 0, new_block)
    { is_valid, new_block }
  end

  defp move_block_down(model) do
    new_block = Block.move_down(model.current_block)
    is_valid = validate(model, 0, 1, new_block)
    { is_valid, new_block }
  end

  defp rotate_block(model) do
    new_block = Block.rotate(model.current_block)
    is_valid = validate(model, 0, 0, new_block)
    { is_valid, new_block }
  end

  defp validate(%{ board: board }, offset_x \\ 0, offset_y \\ 0, block \\ nil) do
    next_x = block.x + offset_x
    next_y = block.y + offset_y

    Enum.any?(0..@number_of_stone-1, fn y ->
      Enum.any?(0..@number_of_stone-1, fn x ->
        # if not (block.shape && block.shape[y][x]) do
        #   next
        # end
        board_x = x + next_x
        board_y = y + next_y
        # row = Enum.at(board, board_y) || []
        # val = Enum.at(row, board_x) || 0
        row = Enum.at(board, board_y)
        val = if row, do: Enum.at(row, board_x), else: nil
        is_outside_left_wall = board_x < 0
        is_outside_right_wall = board_x >= @cols
        is_under_bottom = board_y >= @logical_rows
        is_outside_board = board_y >= length(board) || board_x >= length(row)
        is_exists_block = (not is_outside_board) and val > 0
        not (is_outside_left_wall or is_outside_right_wall or is_under_bottom or is_outside_board or is_exists_block)
      end)
    end)
  end
end

Ratatouille.run(Tetris, interval: 1000)
