defmodule RotationalCipher do
  @doc """
  Given a plaintext and amount to shift by, return a rotated string.

  Example:
  iex> RotationalCipher.rotate("Attack at dawn", 13)
  "Nggnpx ng qnja"
  """
  @spec rotate(text :: String.t(), shift :: integer) :: String.t()
  def rotate(text, shift) do
    text
    |> String.codepoints
    |> Enum.map(fn
      <<u>> when u in ?A..?Z ->
        distance = rem(u - ?A + shift, 26)
        <<?A + distance>>
      <<l>> when l in ?a..?z ->
        distance = rem(l - ?a + shift, 26)
        <<?a + distance>>
      c -> c
    end)
    |> Enum.join
  end
end
