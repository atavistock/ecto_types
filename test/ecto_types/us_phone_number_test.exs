defmodule EctoTypes.UsPhoneNumberTest do
  use DataCase

  alias EctoTypes.UsPhoneNumber

  describe "phones" do
    test "dump/1 returns a 10 digit number for US phone numbers in any format" do
      assert UsPhoneNumber.dump("415 555 1212") == {:ok, 4_155_551_212}
      assert UsPhoneNumber.dump("(415)555-1212") == {:ok, 4_155_551_212}
      assert UsPhoneNumber.dump("  415 555 1212") == {:ok, 4_155_551_212}
    end

    test "dump/1 returns a 10 digit number for US phone numbers with a leading '1'" do
      assert UsPhoneNumber.dump("1 (415) 555-1212") == {:ok, 4_155_551_212}
      assert UsPhoneNumber.dump("+1 (415) 555 - 1212") == {:ok, 4_155_551_212}
    end

    test "dump/1 returns nil for non-US phone number formats" do
      assert UsPhoneNumber.dump(nil) == :error
      assert UsPhoneNumber.dump("abc") == :error
      assert UsPhoneNumber.dump("1234") == :error
      assert UsPhoneNumber.dump(1234) == :error
      assert UsPhoneNumber.dump("+12 345 678 9012") == :error
    end

    test "load/1 returns a formatted phone number string from a 10 digit numeric value" do
      assert UsPhoneNumber.load(4_155_551_212) == {:ok, "1 (415) 555-1212"}
    end

    test "load/1 returns an error if the 10 digit numeric value starts with '1'" do
      assert UsPhoneNumber.load(1_155_551_212) == :error
    end

    test "load/1 returns nil unless its 10 digit numeric value" do
      assert UsPhoneNumber.load(123_456_789) == :error
      assert UsPhoneNumber.load("1 (415) 555-1212") == :error
    end
  end
end
