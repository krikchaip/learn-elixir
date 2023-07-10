defmodule TopSecret do
  def to_ast(string), do: Code.string_to_quoted!(string)

  defguardp is_def?(ast)
            when (is_tuple(ast) and
                    elem(ast, 0) == :def) or
                   elem(ast, 0) == :defp

  defguardp no_args?(args)
            when is_nil(args) or
                   length(args) == 0

  def decode_secret_message_part({_def, _, [head, _body]} = ast, acc)
      when is_def?(ast) do
    case head do
      {_, _, args} when no_args?(args) ->
        {ast, ["" | acc]}

      {:when, _, when_args} ->
        [{name, _, args} | _guards] = when_args
        {ast, [take(name, length(args)) | acc]}

      {name, _, args} ->
        {ast, [take(name, length(args)) | acc]}
    end
  end

  def decode_secret_message_part(ast, acc), do: {ast, acc}

  def decode_secret_message(string) do
    string
    |> to_ast
    |> Macro.prewalk([], &decode_secret_message_part/2)
    |> elem(1)
    |> Enum.reverse()
    |> Enum.join()
  end

  defp take(atom, n), do: atom |> to_string |> String.slice(0..(n - 1))
end
