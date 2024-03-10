defmodule EctoTypes.TokenTest do
  use ExUnit.Case, async: true

  alias EctoTypes.Token

  import Ecto.UUID, only: [bingenerate: 0]

  setup do
    token_signing_salt = System.get_env("TOKEN_SIGNING_SALT")
    System.put_env("TOKEN_SIGNING_SALT", "abcdefghijklmnop")

    if is_binary(token_signing_salt) do
      on_exit(fn -> System.put_env("TOKEN_SIGNING_SALT", token_signing_salt) end)
    else
      on_exit(fn -> System.delete_env("TOKEN_SIGNING_SALT") end)
    end
  end

  describe "token_type" do
    test "load/1" do
      raw_uuid = bingenerate()
      {:ok, token} = Token.load(raw_uuid)
      assert String.length(token) == 24
    end

    test "load/1 and dump/1 convert back and forth to a binary uuid" do
      raw_uuid = bingenerate()
      {:ok, signed_token} = Token.load(raw_uuid)
      assert Token.dump(signed_token) == {:ok, raw_uuid}
    end

    test "cast/2 only validates length" do
      raw_uuid = bingenerate()
      {:ok, good_token} = Token.load(raw_uuid)
      assert Token.cast(good_token) == {:ok, good_token}
      assert Token.cast(good_token <> "1") == :error
      assert Token.cast("1") == :error
    end
  end
end
