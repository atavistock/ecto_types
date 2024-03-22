defmodule EctoTypes.Types.UsPhoneNumber do
  @moduledoc """
    Behaviors for normalizing, storing, and retrieving US phone numbers.

    Any string which can be reduced to an 11 digit number with a "1" prefix or a 10 digit
    number, is considered a valid US format number.  This can be stored in the
    database as a :bigint field rather than a string.  When retrieved from the database it
    will be reformated into a string in a standard US format as "1(nnn)nnn-nnnn".

    There is no validation for actual real world phone numbers, only that they are in the
    correct format.
  """

  use Ecto.Type

  @split ~r/^(\d{3})(\d{3})(\d{4})$/
  @format "1 (\\1) \\2-\\3"

  defguardp ten_digit_numeric(value) when is_binary(value) and byte_size(value) == 10

  defguardp integer_phone_bounds(value)
            when is_integer(value) and value > 1_999_999_999 and value < 9_999_999_999

  @impl Ecto.Type
  def type, do: :int8

  @impl Ecto.Type
  @spec cast(any) :: :error | {:ok, binary}
  def cast(phone) when is_binary(phone), do: {:ok, phone}
  def cast(phone) when is_integer(phone), do: load(phone)
  def cast(_), do: :error

  @impl Ecto.Type
  @spec load(any) :: :error | {:ok, binary}
  def load(value) when ten_digit_numeric(value), do: {:ok, load!(value)}
  def load(number) when integer_phone_bounds(number), do: load(Integer.to_string(number))
  def load(_), do: :error

  @spec load!(any) :: :error | binary
  def load!(value) when ten_digit_numeric(value), do: String.replace(value, @split, @format)
  def load!(number) when integer_phone_bounds(number), do: load!(Integer.to_string(number))
  def load!(_), do: :error

  @impl Ecto.Type
  @spec dump(any) :: :error | {:ok, pos_integer}
  def dump(number) when integer_phone_bounds(number), do: {:ok, number}
  def dump(phone) when is_binary(phone), do: phone |> pure_numeric |> numeralize |> dump
  def dump(_), do: :error

  @spec dump!(any) :: :error | pos_integer
  def dump!(number) when integer_phone_bounds(number), do: number
  def dump!(phone) when is_binary(phone), do: phone |> pure_numeric |> numeralize |> dump!
  def dump!(_), do: :error

  # TODO Move many of these formatting functions to a PhoneFormat module
  @spec valid?(any) :: boolean
  def valid?(number) when integer_phone_bounds(number), do: true
  def valid?(phone) when is_binary(phone), do: phone |> pure_numeric |> numeralize |> valid?
  def valid?(_), do: false

  @spec format(binary | non_neg_integer) :: binary
  def format(nil), do: ""
  def format(:error), do: ""
  def format(0), do: ""
  def format(number) when is_integer(number), do: Integer.to_string(number) |> format()
  def format(phone) when ten_digit_numeric(phone), do: String.replace(phone, @split, @format)
  def format(other) when is_binary(other), do: other

  @spec reformat(binary) :: binary
  def reformat(phone), do: phone |> dump!() |> format()

  @spec strip_one_prefix(binary) :: binary
  def strip_one_prefix("1" <> value), do: value
  def strip_one_prefix(value), do: value

  # Remove any non-numeric letters from a string
  defp pure_numeric(phone), do: phone |> String.replace(~r/\D/, "")

  # Convert a ten digit numeric string into an integer or return :error
  defp numeralize(value) when ten_digit_numeric(value), do: String.to_integer(value)
  defp numeralize("1" <> value) when is_binary(value), do: numeralize(value)
  defp numeralize(_), do: :error
end
