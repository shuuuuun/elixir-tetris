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

  @initial_length 4

  @cols 6
  @rows 12
  @number_of_stone 2
  @hidden_rows @number_of_stone
  @logical_rows @rows + @hidden_rows

  @shape_list [
    [
      [0, 0, 0, 0],
      [1, 1, 1, 1],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
    [
      [0, 0, 0, 0],
      [0, 1, 1, 1],
      [0, 1, 0, 0],
      [0, 0, 0, 0],
    ],
    [
      [0, 0, 0, 0],
      [1, 1, 1, 0],
      [0, 0, 1, 0],
      [0, 0, 0, 0],
    ],
    [
      [0, 0, 0, 0],
      [0, 1, 1, 0],
      [0, 1, 1, 0],
      [0, 0, 0, 0],
    ],
    [
      [0, 0, 0, 0],
      [1, 1, 0, 0],
      [0, 1, 1, 0],
      [0, 0, 0, 0],
    ],
    [
      [0, 0, 0, 0],
      [0, 1, 1, 0],
      [1, 1, 0, 0],
      [0, 0, 0, 0],
    ],
    [
      [0, 0, 0, 0],
      [0, 1, 0, 0],
      [1, 1, 1, 0],
      [0, 0, 0, 0],
    ],
  ]

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
      # current_block: generateBlock(),
      # next_block: generateBlock(),
      direction: :right,
      chain: for(x <- @initial_length..1, do: {x, 0}),
      # food: {7, 7},
      alive: true,
      # height: window.height - 2,
      # width: window.width - 2
      height: @rows,
      width: @cols
    }
  end

  def update(model, msg) do
    case msg do
      {:event, %{key: key}} when key in @arrows -> %{model | direction: next_dir(model.direction, key_to_dir(key))}
      :tick -> tick(model)
      _ -> model
    end
  end

  def subscribe(_model) do
    Subscription.interval(100, :tick)
  end

  def render(%{chain: chain} = model) do
    score = length(chain) - 4

    view do
      panel(
        title: "Tetris Score=#{score}",
        # height: :fill,
        # height: @rows,
        # padding: 0
      ) do
        render_board(model)
      end
    end
  end

  defp render_board(%{alive: false}) do
    label(content: "Game Over")
  end

  defp render_board(model) do
    # %{
    #   chain: [{head_x, head_y} | tail],
    #   # food: {food_x, food_y}
    # } = model
    # head_cell = canvas_cell(x: head_x, y: head_y, char: "@")
    # tail_cells = for {x, y} <- tail, do: canvas_cell(x: x, y: y, char: "O")
    # food_cell = canvas_cell(x: food_x, y: food_y, char: "X")
    shape = Enum.at(@shape_list, 0)
    block_cells = for {row, x} <- Enum.with_index(shape), {val, y} <- Enum.with_index(row), do: canvas_cell(x: x, y: y, char: Integer.to_string(val))

    cells = [
      canvas_cell(x: 1, y: 0, char: "X"),
      canvas_cell(x: 0, y: 1, char: "X"),
      canvas_cell(x: 1, y: 1, char: "X"),
      canvas_cell(x: 2, y: 1, char: "X")
    ]

    # canvas(height: model.height, width: model.width) do
    canvas(height: @cols, width: @rows) do
      # [food_cell, head_cell | tail_cells]
      # cells
      block_cells
    end
  end

  defp tick(model) do
    [head | tail] = model.chain
    # next = next_link(head, model.direction)
    next = head

    cond do
      # not next_valid?(next, model) ->
      #   %{model | alive: false}

      # next == model.food ->
      #   new_food = random_food(model.width - 1, model.height - 1)
      #   %{model | chain: [next, head | tail], food: new_food}

      true ->
        model
        # %{model | chain: [next, head | Enum.drop(tail, -1)]}
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
end

Ratatouille.run(Tetris, interval: 100)
