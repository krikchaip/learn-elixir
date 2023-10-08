defmodule Wordy do
  @doc """
  Calculate the math problem in the sentence.
  """
  @spec answer(String.t()) :: integer
  def answer(question) do
    question
    |> grab_expressions()
    |> parse_expressions()
    |> Enum.reduce(&apply(&1, [&2]))
  end

  defp grab_expressions(question) do
    case Regex.named_captures(~r/What is (?<exp>.*)\?/, question) do
      %{"exp" => exp} -> exp
      _ -> raise ArgumentError
    end
  end

  defp parse_expressions(exp) do
    exp
    |> String.split(~r/ (plus|minus|multiplied by|divided by) /, include_captures: true)
    |> then(fn [starter | rest] -> [starter | Enum.map_every(rest, 2, &String.trim/1)] end)
    |> Enum.map_every(2, &String.to_integer/1)
    |> then(fn [starter | rest] -> [starter | Enum.chunk_every(rest, 2) |> Enum.map(&to_operation/1)] end)
  end

  defp to_operation(["plus", b]), do: fn a -> a + b end
  defp to_operation(["minus", b]), do: fn a -> a - b end
  defp to_operation(["multiplied by", b]), do: fn a -> a * b end
  defp to_operation(["divided by", b]), do: fn a -> a / b end
end
