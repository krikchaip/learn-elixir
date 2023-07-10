defmodule RPNCalculator.Exception do
  defmodule DivisionByZeroError do
    defexception message: "division by zero occurred"
  end

  defmodule StackUnderflowError do
    defexception message: "stack underflow occurred"

    @impl Exception
    def exception([]), do: %__MODULE__{}
    def exception(msg), do: Map.update!(%__MODULE__{}, :message, &(&1 <> ", context: #{msg}"))
  end

  def divide(xs) when length(xs) < 2, do: raise(StackUnderflowError, "when dividing")
  def divide([b, _]) when b == 0, do: raise(DivisionByZeroError)
  def divide([b, a]), do: div(a, b)
end
