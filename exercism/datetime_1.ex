defmodule LibraryFees do
  def datetime_from_string(string) do
    NaiveDateTime.from_iso8601! string
  end

  def before_noon?(datetime) do
    datetime
      |> NaiveDateTime.to_time
      |> then(&(&1 < ~T[12:00:00]))
  end

  @day 24 * 60 * 60
  def return_date(checkout_datetime) do
    checkout_datetime
      |> then(&if before_noon?(&1),
        do:   NaiveDateTime.add(&1, 28 * @day),
        else: NaiveDateTime.add(&1, 29 * @day))
      |> NaiveDateTime.to_date
  end

  def days_late(planned_return_date, actual_return_datetime) do
    return_date = NaiveDateTime.to_date actual_return_datetime
    case Date.diff(return_date, planned_return_date) do
      d when d > 0 -> d
      _ -> 0
    end
  end

  def monday?(datetime) do
    datetime
      |> NaiveDateTime.to_date
      |> then(&Date.day_of_week(&1) == 1)
  end

  def calculate_late_fee(checkout, return, rate) do
    checkout = datetime_from_string checkout
    return = datetime_from_string return

    return_date = return_date checkout
    days_late = days_late return_date, return
    fees = days_late * rate

    if monday?(return), do: Float.floor(fees / 2), else: fees
  end
end
