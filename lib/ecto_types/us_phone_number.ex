defmodule EctoTypes.UsPhoneNumber do
  @moduledoc """
    Behaviors for normalizing, storing, and retrieving US phone numbers.

    Any string which can be reduced to an 11 digit number with a "1" prefix or a ten
    digit number, is considered a valid US format number.  This can be stored in the
    database as a :bigint field rather than a string.  When retrieved from the database
    it will be reformated into a string in a standard US format as `1 (nnn) nnn-nnnn`.

    There is no validation for real world phone numbers, only that they are in the
    correct format.
  """

  use Ecto.Type

  @split ~r/^(\d{3})(\d{3})(\d{4})$/
  @format "1 (\\1) \\2-\\3"

  defguardp ten_digit_numeric(value) when is_binary(value) and byte_size(value) == 10

  defguardp integer_phone_bounds(value)
            when is_integer(value) and value > 1_999_999_999 and value < 9_999_999_999

  @impl Ecto.Type
  def type do
    :int8
  end

  @impl Ecto.Type
  @spec cast(any) :: :error | {:ok, binary}
  def cast(value) when is_binary(value) do
    {:ok, value}
  end

  def cast(value) when is_integer(value) do
    load(value)
  end

  def cast(_) do
    :error
  end

  @impl Ecto.Type
  @spec load(any) :: :error | {:ok, binary}
  def load(value) when ten_digit_numeric(value) do
    {:ok, load!(value)}
  end

  def load(number) when integer_phone_bounds(number) do
    number |> Integer.to_string() |> load()
  end

  def load(_) do
    :error
  end

  @impl Ecto.Type
  @spec dump(any) :: :error | {:ok, pos_integer}
  def dump(number) when integer_phone_bounds(number) do
    {:ok, number}
  end

  def dump(value) when is_binary(value) do
    value |> scrub_phone_string() |> dump()
  end

  def dump(_) do
    :error
  end

  @spec load!(any) :: :error | binary
  def load!(value) when ten_digit_numeric(value) do
    value |> String.replace(@split, @format)
  end

  def load!(number) when integer_phone_bounds(number) do
     number |> Integer.to_string() |> load!()
  end

  def load!(_) do
     :error
  end

  @spec dump!(any) :: :error | pos_integer
  def dump!(number) when integer_phone_bounds(number) do
     number
  end

  def dump!(value) when is_binary(value) do
     value |> scrub_phone_string() |> dump!()
  end

  def dump!(_) do
     :error
  end

  @doc "
    Validate a phone number as either a ten digit number or a number with a leading '1'
  "
  @spec valid?(any) :: boolean
  def valid?(number) when integer_phone_bounds(number) do
     true
  end

  def valid?(value) when is_binary(value) do
     value |> scrub_phone_string() |> valid?()
  end

  def valid?(_) do
     false
  end

  @doc "
    Format a phone number into a standard US format or return an empty string
  "
  @spec format(binary | non_neg_integer) :: binary
  def format(nil), do: ""
  def format(:error), do: ""
  def format(0), do: ""

  def format(number) when is_integer(number) do
     number |> Integer.to_string() |> format()
  end

  def format(value) when ten_digit_numeric(value) do
     value |> String.replace(@split, @format)
  end

  def format(value) when is_binary(value) do
     value |> dump!() |> format()
  end

  # Convert a ten digit numeric string into an integer or return :error
  @spec scrub_phone_string(binary) :: :error | pos_integer
  defp scrub_phone_string("1" <> value) when ten_digit_numeric(value) do
    value |> String.to_integer()
  end

  defp scrub_phone_string(value) when ten_digit_numeric(value) do
     value |> String.to_integer()
  end

  defp scrub_phone_string(value) when is_binary(value) do
    value |> String.replace(~r/\D/, "") |> scrub_phone_string()
  end

  defp scrub_phone_string(_) do
     :error
  end
end
