defmodule AffineCipher do
  @typedoc """
  A type for the encryption key
  """
  @type key() :: %{a: integer, b: integer}

  @doc """
  Encode an encrypted message using a key
  """
  @spec encode(key :: key(), message :: String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def encode(%{a: a, b: b}, message) do
    if coprime?(a, 26) do
      message
      |> String.replace(~r/[[:space:][:punct:]]+/, "")
      |> String.downcase()
      |> String.codepoints()
      |> Enum.map(fn <<i>> = s ->
        case Integer.parse(s) do
          {_int, _} -> s
          :error -> ?a..?z |> Enum.at(rem(a * (i - ?a) + b, 26)) |> then(&<<&1>>)
        end
      end)
      |> Enum.chunk_every(5)
      |> Enum.map(&Enum.join/1)
      |> Enum.join(" ")
      |> then(&{:ok, &1})
    else
      {:error, "a and m must be coprime."}
    end
  end

  @doc """
  Decode an encrypted message using a key
  """
  @spec decode(key :: key(), message :: String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def decode(%{a: a, b: b}, encrypted) do
    if coprime?(a, 26) do
      encrypted
      |> String.split()
      |> Enum.join()
      |> String.codepoints()
      |> Enum.map(fn <<y>> = s ->
        case Integer.parse(s) do
          {_int, _} -> s
          :error -> ?a..?z |> Enum.at(rem(mmi(a, 26) * (y - ?a - b), 26)) |> then(&<<&1>>)
        end
      end)
      |> Enum.join()
      |> then(&{:ok, &1})
    else
      {:error, "a and m must be coprime."}
    end
  end

  defp coprime?(a, m), do: Integer.gcd(a, m) == 1

  # Modular Multiplicative Inverse -> the answer should fall within the range 1..m-1
  # ref: https://www.geeksforgeeks.org/multiplicative-inverse-under-modulo-m
  defp mmi(a, m), do: Integer.extended_gcd(a, m) |> elem(1)
end
