defmodule Bob do
  @spec hey(String.t()) :: String.t()
  def hey(input) do
    cond do
      yell?(input) and question?(input) -> "Calm down, I know what I'm doing!"
      yell?(input)                      -> "Whoa, chill out!"
      question?(input)                  -> "Sure."
      silence?(input)                   -> "Fine. Be that way!"
      true                              -> "Whatever."
    end
  end

  defp question?(s), do: s =~ ~r/\?\s*$/
  defp yell?(s), do: String.upcase(s) == s and s =~ ~r/[[:alpha:]]+/
  defp silence?(s), do: s =~ ~r/^\s*$/
end
