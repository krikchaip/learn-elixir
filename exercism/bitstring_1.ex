defmodule DNA do
  def encode_nucleotide(code_point) do
    case code_point do
      ?A -> 0b0001
      ?C -> 0b0010
      ?G -> 0b0100
      ?T -> 0b1000
      ?\s -> 0b0000
    end
  end

  def decode_nucleotide(encoded_code) do
    case encoded_code do
      0b0001 -> ?A
      0b0010 -> ?C
      0b0100 -> ?G
      0b1000 -> ?T
      0b0000 -> ?\s
    end
  end

  def encode(dna), do: do_encode(dna, <<>>)

  defp do_encode([], acc), do: acc
  defp do_encode([code_point | rest], acc) do
    b = encode_nucleotide(code_point)
    do_encode(rest, <<acc::bitstring, b::4>>)
  end

  def decode(dna), do: do_decode(dna, [])

  defp do_decode(<<>>, acc), do: acc
  defp do_decode(<<encoded_code::4, rest::bitstring>>, acc) do
    c = decode_nucleotide(encoded_code)
    do_decode(rest, acc ++ [c])
  end
end
