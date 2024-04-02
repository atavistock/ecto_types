defmodule EctoTypes.Token do
  @moduledoc """
    A distinct token to use in urls.

    At the database this is backed by a UUID field (128-bits), but also includes a 16-bit checksum to
    quickly invalidate and avoid hitting the database.  This appears as a 26 character base-32
    alphanumeric token for use in urls.

    At the database level this should be a UUID field with a default UUIDv4 value set as
    ```
    DEFAULT gen_random_uuid() NOT NULL
    ```
  """

  use Ecto.Type

  @salt_length 4
  @data_length 26
  @signed_length @salt_length + @data_length

  @impl Ecto.Type
  @spec type :: :uuid
  def type, do: :uuid

  @impl Ecto.Type
  @spec cast(any) :: {:ok, binary} | :error
  def cast(<<_::binary-size(@signed_length)>> = signed_token) do
    {:ok, signed_token}
  end

  def cast(_) do
    :error
  end

  @impl Ecto.Type
  @spec load(any) :: {:ok, binary} | :error
  def load(<<_::128>> = raw_uuid) do
    Base.encode32(raw_uuid, padding: false) |> sign
  end

  def load(_) do
    :error
  end

  @impl Ecto.Type
  @spec dump(any) :: {:ok, binary} | :error
  def dump(<<_::bytes-size(@signed_length)>> = signed_token) do
    with {:ok, unsigned_token} <- verify(signed_token),
         {:ok, raw_uuid} <- Base.decode32(unsigned_token, padding: false) do
      {:ok, raw_uuid}
    else
      _ -> :error
    end
  end

  def dump(_) do
    :error
  end

  @spec create :: {:ok, binary} | :error
  @doc "Creates a random new token"
  def create do
    :crypto.strong_rand_bytes(16) |> load()
  end

  @spec uuid_to_token(binary) :: :error | {:ok, binary}
  @doc "Helper converting from UUID binary into a token binary."
  def uuid_to_token(uuid) do
    {:ok, raw_uuid} = uuid |> Ecto.UUID.dump()
    raw_uuid |> load()
  end

  @spec sign(any) :: {:ok, binary} | :error
  defp sign(<<_::binary-size(@data_length)>> = unsigned_token) do
    salt =
      :crypto.hash(
        :blake2s,
        ~s[#{unsigned_token}#{System.get_env("TOKEN_SIGNING_SALT")}]
      )
      |> Base.encode32(padding: false)
      |> binary_part(0, @salt_length)

    {:ok, "#{salt}#{unsigned_token}"}
  end

  defp sign(_) do
    :error
  end

  @spec verify(any) :: {:ok, binary} | :error
  defp verify(
         <<_::binary-size(@salt_length), unsigned_token::binary-size(@data_length)>> =
           signed_token
       ) do
    with {:ok, check_token} <- sign(unsigned_token),
         true <- signed_token == check_token do
      {:ok, unsigned_token}
    else
      _ -> :error
    end
  end

  defp verify(_) do
    :error
  end

end
