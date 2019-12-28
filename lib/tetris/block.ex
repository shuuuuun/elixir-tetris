defmodule Tetris.Block do
  alias Tetris.Block

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

  defstruct [:shape, :block_id, x: 0, y: 0]

  def new(id, x, y) do
    %Block{
      shape: Enum.at(@shape_list, id),
      # block_id: id,
      x: x,
      y: y,
    }
  end

  def random(x, y) do
    %Block{
      shape: Enum.random(@shape_list),
      # block_id: id,
      x: x,
      y: y,
    }
  end

  def move_left(block) do
    %Block{ block | x: block.x - 1 }
  end

  def move_right(block) do
    %Block{ block | x: block.x + 1 }
  end

  def move_down(block) do
    %Block{ block | y: block.y + 1 }
  end

  def rotate(block) do
    shape_size = Enum.count(block.shape)
    new_shape =
      Enum.with_index(block.shape) |> Enum.map(fn {row, y} ->
        Enum.with_index(row) |> Enum.map(fn {val, x} ->
          block.shape |> Enum.at(shape_size - 1 - x, []) |> Enum.at(y, 0)
        end)
      end)
    %Block{ block | shape: new_shape }
  end
end
