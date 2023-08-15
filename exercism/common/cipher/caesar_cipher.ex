defmodule SimpleCipher do
  @doc """
  Given a `plaintext` and `key`, encode each character of the `plaintext` by
  shifting it by the corresponding letter in the alphabet shifted by the number
  of letters represented by the `key` character, repeating the `key` if it is
  shorter than the `plaintext`.

  For example, for the letter 'd', the alphabet is rotated to become:

  defghijklmnopqrstuvwxyzabc

  You would encode the `plaintext` by taking the current letter and mapping it
  to the letter in the same position in this rotated alphabet.

  abcdefghijklmnopqrstuvwxyz
  defghijklmnopqrstuvwxyzabc

  "a" becomes "d", "t" becomes "w", etc...

  Each letter in the `plaintext` will be encoded with the alphabet of the `key`
  character in the same position. If the `key` is shorter than the `plaintext`,
  repeat the `key`.

  Example:

  plaintext = "testing"
  key = "abc"

  The key should repeat to become the same length as the text, becoming
  "abcabca". If the key is longer than the text, only use as many letters of it
  as are necessary.
  """
  def encode(plaintext, key) when byte_size(plaintext) > byte_size(key) do
    plaintext = to_charlist(plaintext)
    key = to_charlist(key) |> Stream.cycle() |> Enum.take(length(plaintext))
    encode(plaintext, key)
  end

  def encode(plaintext, key) when byte_size(plaintext) < byte_size(key) do
    plaintext = to_charlist(plaintext)
    key = to_charlist(key) |> Enum.take(length(plaintext))
    encode(plaintext, key)
  end

  def encode(plaintext, key) when byte_size(plaintext) == byte_size(key) do
    plaintext = to_charlist(plaintext)
    key = to_charlist(key)
    encode(plaintext, key)
  end

  def encode(plaintext, key) do
    Enum.zip_reduce(plaintext, key, "", fn
      p, k, result -> result <> <<translate(p, k, :forward)>>
    end)
  end

  @doc """
  Given a `ciphertext` and `key`, decode each character of the `ciphertext` by
  finding the corresponding letter in the alphabet shifted by the number of
  letters represented by the `key` character, repeating the `key` if it is
  shorter than the `ciphertext`.

  The same rules for key length and shifted alphabets apply as in `encode/2`,
  but you will go the opposite way, so "d" becomes "a", "w" becomes "t",
  etc..., depending on how much you shift the alphabet.
  """
  def decode(ciphertext, key) when byte_size(ciphertext) > byte_size(key) do
    ciphertext = to_charlist(ciphertext)
    key = to_charlist(key) |> Stream.cycle() |> Enum.take(length(ciphertext))
    decode(ciphertext, key)
  end

  def decode(ciphertext, key) when byte_size(ciphertext) < byte_size(key) do
    ciphertext = to_charlist(ciphertext)
    key = to_charlist(key) |> Enum.take(length(ciphertext))
    decode(ciphertext, key)
  end

  def decode(ciphertext, key) when byte_size(ciphertext) == byte_size(key) do
    ciphertext = to_charlist(ciphertext)
    key = to_charlist(key)
    decode(ciphertext, key)
  end

  def decode(ciphertext, key) do
    Enum.zip_reduce(ciphertext, key, "", fn
      p, k, result -> result <> <<translate(p, k, :backward)>>
    end)
  end

  @doc """
  Generate a random key of a given length. It should contain lowercase letters only.
  """
  def generate_key(0), do: ""

  def generate_key(length) when length > 0 do
    <<Enum.random(?a..?z), generate_key(length - 1)::binary>>
  end

  defp translate(char, by, dir) do
    adjust =
      case dir do
        :forward -> fn x, y -> x + (y - ?a) end
        :backward -> fn x, y -> x - (y - ?a) end
      end

    case adjust.(char, by) do
      t when t > ?z -> ?a + (t - ?z) - 1
      t when t < ?a -> ?z - (?a - t) + 1
      t -> t
    end
  end
end
