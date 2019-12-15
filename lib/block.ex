defmodule Block do
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
    # newShape = []
    # for y in range(NUMBER_OF_BLOCK):
    #     newShape.append([])
    #     for x in range(NUMBER_OF_BLOCK):
    #         newShape[y].append(self.shape[NUMBER_OF_BLOCK - 1 - x][y])
    # self.shape = newShape
    %Block{ block | shape: [] }
  end
end
