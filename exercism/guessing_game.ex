defmodule GuessingGame do
  # def compare(_), do: "Make a guess"

  def compare(secret_number, guess \\ :no_guess)
  def compare(_, :no_guess), do: "Make a guess"
  def compare(secret_number, guess) when guess == secret_number, do: "Correct"
  def compare(secret_number, guess) when guess + 1 == secret_number, do: "So close"
  def compare(secret_number, guess) when guess - 1 == secret_number, do: "So close"
  def compare(secret_number, guess) when guess > secret_number, do: "Too high"
  def compare(secret_number, guess) when guess < secret_number, do: "Too low"
end
