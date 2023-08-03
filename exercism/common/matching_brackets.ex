defmodule MatchingBrackets do
  @close_brackets %{?( => ?), ?[ => ?], ?{ => ?}}

  @doc """
  Checks that all the brackets and braces in the string are matched correctly, and nested correctly
  """
  @spec check_brackets(String.t()) :: boolean
  def check_brackets(exp), do: do_check_brackets(exp, [])

  defp do_check_brackets("", brackets), do: length(brackets) == 0
  defp do_check_brackets(<<c, rest::binary>>, brackets)
    when c in '([{', do: do_check_brackets(rest, [c | brackets])
  defp do_check_brackets(<<c, rest::binary>>, [b | brackets])
    when c in ')]}', do: c == @close_brackets[b] && do_check_brackets(rest, brackets)
  defp do_check_brackets(<<c, _::binary>>, [])
    when c in ')]}', do: false
  defp do_check_brackets(<<_, rest::binary>>, brackets), do: do_check_brackets(rest, brackets)
end
