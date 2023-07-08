defmodule LogParser do
  def valid_line?(line) do
    line =~ ~r/^\[DEBUG\]/ or
    line =~ ~r/^\[INFO\]/ or
    line =~ ~r/^\[WARNING\]/ or
    line =~ ~r/^\[ERROR\]/
  end

  def split_line(line) do
    String.split(line, ~r/<[~*=-]*>/)
  end

  def remove_artifacts(line) do
    String.replace line, ~r/end-of-line\d+/i, ""
  end

  def tag_with_user_name(line) do
    pattern = ~r/User[[:space:]]+([[:^space:]]+)[[:space:]]*/
    case Regex.run pattern, line do
      [_, user] -> "[USER] #{user} #{line}"
      nil       -> line
    end
  end
end
