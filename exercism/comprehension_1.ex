defmodule Grep do
  @spec grep(String.t(), [String.t()], [String.t()]) :: String.t()
  def grep(pattern, flags, files) do
    for file_name <- files,
        {:ok, content} <- [File.read(file_name)],
        {line, line_number} <- content |> String.split("\n", trim: true) |> Enum.with_index(1),
        is_matched <- [line =~ Regex.compile!(
          if("-x" in flags, do: "^#{pattern}$", else: pattern),
          if("-i" in flags, do: "i", else: "")
        )],
        if("-v" in flags, do: !is_matched, else: is_matched),
        into: "",
        uniq: true do
      cond do
        "-l" in flags -> "#{file_name}\n"
        "-n" in flags -> "#{line_number}:#{line}\n"
          |> then(&if length(files) > 1, do: "#{file_name}:#{&1}", else: &1)
        true -> "#{line}\n"
          |> then(&if length(files) > 1, do: "#{file_name}:#{&1}", else: &1)
      end
    end
  end
end
