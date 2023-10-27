defmodule Diamond do
  @doc """
  Given a letter, it prints a diamond starting with 'A',
  with the supplied letter at the widest point.
  """
  @spec build_shape(char) :: String.t()
  def build_shape(char) do
    full_length = 2 * (char - ?A) + 1
    chars = Enum.to_list(?A..char) ++ Enum.to_list(char-1..?A)

    draw_square(full_length, " ")
    |> fill_diamond(full_length, chars)
    |> Enum.map(fn line -> List.to_string(line) <> "\n" end)
    |> Enum.join()
  end

  defp draw_square(len, space_char \\ ?.) do
    space_char
    |> Stream.duplicate(len)
    |> Enum.to_list()
    |> Stream.duplicate(len)
    |> Enum.to_list()
  end

  defp fill_diamond(square, len, chars) do
    mid_point = div(len, 2)

    Enum.with_index(square, fn line, i ->
      char = Enum.at(chars, i)

      {mid_offset_left, mid_offset_right} = case i do
        i when i > mid_point -> {i - mid_point, len - 1 - i + mid_point}
        i when i <= mid_point -> {mid_point - i, mid_point + i}
      end

      line
      |> List.replace_at(mid_offset_left, char)
      |> List.replace_at(mid_offset_right, char)
    end)
  end
end
