defmodule Clock do
  defstruct hour: 0, minute: 0

  defimpl String.Chars, for: __MODULE__ do
    def to_string(%Clock{hour: h, minute: m}) do
      hh = h |> Kernel.to_string |> String.pad_leading(2, "0")
      mm = m |> Kernel.to_string |> String.pad_leading(2, "0")
      "#{hh}:#{mm}"
    end
  end

  @doc """
  Returns a clock that can be represented as a string:

      iex> Clock.new(8, 9) |> to_string
      "08:09"
  """
  @spec new(integer, integer) :: Clock
  def new(hour, minute) do
    ~T[00:00:00]
    |> Time.add(hour, :hour)
    |> Time.add(minute, :minute)
    |> then(&%Clock{hour: &1.hour, minute: &1.minute})
  end

  @doc """
  Adds two clock times:

      iex> Clock.new(10, 0) |> Clock.add(3) |> to_string
      "10:03"
  """
  @spec add(Clock, integer) :: Clock
  def add(%Clock{hour: hour, minute: minute}, add_minute) do
    Time.new!(hour, minute, 0)
    |> Time.add(add_minute, :minute)
    |> then(&%Clock{hour: &1.hour, minute: &1.minute})
  end
end
