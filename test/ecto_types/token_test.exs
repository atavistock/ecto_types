defmodule Types.TokenTest do
  @moduledoc "Test coverage for the Types.Token module"

  use DataCase

  alias EctoTypes.Token

  setup do
    token_signing_salt = System.get_env("TOKEN_SIGNING_SALT")
    System.put_env("TOKEN_SIGNING_SALT", "abcdefghijklmnop")

    if is_nil(TOKEN_SIGNING_SALT) do
      on_exit(fn -> System.delete_env("TOKEN_SIGNING_SALT") end)
    else
      on_exit(fn -> System.put_env("TOKEN_SIGNING_SALT", token_signing_salt) end)
    end
  end

  describe "token_type" do
    test "load/1" do
      raw_uuid = Ecto.UUID.bingenerate()
      {:ok, token} = Token.load(raw_uuid)
      assert String.length(token) == 30
    end

    test "load/1 and dump/1 convert back and forth to a binary uuid" do
      raw_uuid = Ecto.UUID.bingenerate()
      {:ok, signed_token} = Token.load(raw_uuid)
      assert Token.dump(signed_token) == {:ok, raw_uuid}
    end

    test "cast/2 only validates length" do
      raw_uuid = Ecto.UUID.bingenerate()
      {:ok, good_token} = Token.load(raw_uuid)
      assert Token.cast(good_token) == {:ok, good_token}
      assert Token.cast(good_token <> "1") == :error
      assert Token.cast("1") == :error
    end
  end
end
