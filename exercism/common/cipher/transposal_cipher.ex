defmodule Atbash do
  @cipher_table Enum.zip(?a..?z, ?z..?a) |> Map.new

  @doc """
  Encode a given plaintext to the corresponding ciphertext

  ## Examples

  iex> Atbash.encode("completely insecure")
  "xlnko vgvob rmhvx fiv"
  """
  @spec encode(String.t()) :: String.t()
  def encode(plaintext) do
    plaintext
    |> String.replace(~r/[^[:alnum:]]+/, "")
    |> String.codepoints
    |> Stream.map(&String.downcase/1)
    |> Stream.map(fn
      <<c>> when is_map_key(@cipher_table, c) -> <<@cipher_table[c]>>
      s -> s
    end)
    |> Stream.chunk_every(5)
    |> Enum.join(" ")
  end

  @spec decode(String.t()) :: String.t()
  def decode(cipher) do
    cipher
    |> String.replace(" ", "")
    |> String.codepoints
    |> Enum.map(fn
      <<c>> when is_map_key(@cipher_table, c) -> <<@cipher_table[c]>>
      s -> s
    end)
    |> Enum.join
  end
end
