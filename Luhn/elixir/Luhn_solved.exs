defmodule Luhn do
  def valid?(cc) when is_binary(cc), do: String.to_integer(cc) |> valid?
  def valid?(cc) when is_integer(cc) do
    0 == Integer.digits(cc)
         |> Enum.reverse
         |> Enum.chunk_every(2, 2, [0])
         |> Enum.reduce(0, fn([odd, even], sum) -> Enum.sum([sum, odd | Integer.digits(even*2)]) end)
         |> rem(10)
  end
end

ExUnit.start()
defmodule LuhnTest do
  use ExUnit.Case, async: true

  test "49927398716" do
    assert Luhn.valid?(49927398716)
  end
  test "49927398717" do
    refute Luhn.valid?(49927398717)
  end
  test "1234567812345678" do
    refute Luhn.valid?(1234567812345678)
  end
  test "1234567812345670" do
    assert Luhn.valid?(1234567812345670)
  end
end
