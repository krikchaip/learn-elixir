defmodule BankAccount do
  @moduledoc """
  A bank account that supports access from multiple processes.
  """

  @typedoc """
  An account handle.
  """
  @opaque account :: pid

  @doc """
  Open the bank account, making it available for further operations.
  """
  @spec open() :: account
  def open() do
    {:ok, pid} = Agent.start(fn -> 0 end)
    pid
  end

  @doc """
  Close the bank account, making it unavailable for further operations.
  """
  @spec close(account) :: any
  def close(account) do
    Agent.stop(account)
  end

  @doc """
  Get the account's balance.
  """
  @spec balance(account) :: integer | {:error, :account_closed}
  def balance(account) do
    if not Process.alive?(account) do
      {:error, :account_closed}
    else
      Agent.get(account, & &1)
    end
  end

  @doc """
  Add the given amount to the account's balance.
  """
  @spec deposit(account, integer) :: :ok | {:error, :account_closed | :amount_must_be_positive}
  def deposit(_, amount) when amount <= 0, do: {:error, :amount_must_be_positive}
  def deposit(account, amount) do
    if not Process.alive?(account) do
      {:error, :account_closed}
    else
      Agent.update(account, & &1 + amount)
    end
  end

  @doc """
  Subtract the given amount from the account's balance.
  """
  @spec withdraw(account, integer) ::
          :ok | {:error, :account_closed | :amount_must_be_positive | :not_enough_balance}
  def withdraw(_, amount) when amount <= 0, do: {:error, :amount_must_be_positive}
  def withdraw(account, amount) do
    cond do
      not Process.alive?(account) -> {:error, :account_closed}
      Agent.get(account, & &1) < amount -> {:error, :not_enough_balance}
      true -> Agent.update(account, & &1 - amount)
    end
  end
end
