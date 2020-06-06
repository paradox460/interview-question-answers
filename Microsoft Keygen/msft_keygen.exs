# In the 90s, Microsoft used a very simple algorithm for determining validity
# of software keys. This applies to Windows 95, Office 95, and NT4, as well as
# other software products, such as Encarta.
#
# There are two major types of keys, 10-digit keys and OEM keys.
#
# 10-digit keys take the format of XXX-XXXXXXX.
# The first 3 digits can be any value except repeating digits of 3-9.
# The second 7 digits have the following restrictions
#  - The sum of the digits must be evenly divisible by 7
#  - The last digit cannot be 0 or >= 8
#
# OEM keys are a little more complicated.
# They take the form of XXXXX-OEM-XXXXXXX-XXXXX
# The first segment is actually a date. The first 3 digits are a julian or
#   ordinal date, and are a number between 1 and 366. The second 2 digits are a
#   year, between 95 and 03.
# The second segment must always be the letters OEM
# The third segment is the same as the above 10-digit keys, with one exception:
#   The first digit must be 0.
# The fourth segment can be anything, provided its appropriate length
#
#
# Task
# - Write a function that will check a given CD key thats valid. Your function
#   should support both 10-digit and OEM keycodes
# – Write a function that will generate valid keycodes, letting the user choose
#   between OEM and 10-digit keycodes. Make an attempt to have the function
#   generate as random a value as possible.
#
# Make every attempt to make your program "elixir-y".

defmodule MicrosoftKeys do
  @doc """
  Checks a given key for validity
  """

  @spec valid?(String.t()) :: boolean()
  @invalid_sites for digit <- 3..9, do: (digit * 111) |> Integer.to_string()
  @invalid_lasts ~w[0 8 9]
  def valid?(<<site::binary-size(3), ?-, key::binary-size(6), last::binary-size(1)>>)
      when site not in @invalid_sites and last not in @invalid_lasts do
    key = key <> last

    if not (key =~ ~r/\d{7}/i) do
      false
    else
      valid_key?(key)
    end
  end

  @valid_years ~w[95 96 97 98 99 00 01 02 03]
  def valid?(
        <<day::binary-size(3), year::binary-size(2), "-OEM-0", key::binary-size(5),
          last::binary-size(1), ?-, _rest::binary-size(5)>>
      )
      when last not in @invalid_lasts and year in @valid_years do
    with true <- String.to_integer(day) in 1..366,
         true <- valid_key?(key <> last) do
      true
    else
      _ -> false
    end
  end

  def valid?(_), do: false

  defp valid_key?(key) do
    key
    |> String.graphemes()
    |> Enum.reduce(0, fn d, acc ->
      d |> String.to_integer() |> Kernel.+(acc)
    end)
    |> Integer.mod(7)
    |> Kernel.==(0)
  end

  @doc """
  Generates a valid key of type type
  """
  @spec generate_key(:ten_digit | :oem) :: String.t()
  @randpool for n <- 0..9, do: Integer.to_string(n)
  def generate_key(:ten_digit) do
    [Enum.take_random(@randpool, 3), "-", random_seven()] |> List.flatten() |> Enum.join()
  end

  @randyear ~w[95 96 97 98 99 00 01 02 03]
  def generate_key(:oem) do
    day = format("~3..0B", [:rand.uniform(366)])
    year = Enum.take_random(@randyear, 1)
    key = random_seven([0]) |> Enum.join()
    final = format("~5..0B", [:rand.uniform(99_999)])
    [day, year, "-OEM-", key, "-", final] |> List.flatten() |> Enum.join()
  end

  defp random_seven(_ \\ [])

  defp random_seven([]) do
    random_seven([clamped_random()])
  end

  defp random_seven(sev) when length(sev) > 4 do
    last =
      sev
      |> Enum.sum()
      |> Integer.mod(7)
      |> Kernel.-(7)
      |> Kernel.abs()

    [Enum.reverse(sev), 7, last] |> List.flatten()
  end

  defp random_seven(sev) do
    [clamped_random() | sev] |> random_seven()
  end

  defp clamped_random(), do: :rand.uniform(10) - 1

  defp format(format_str, data \\ []) do
    :io_lib.format(format_str, data) |> List.to_string()
  end
end

# DO NOT EDIT BELOW THIS LINE
ExUnit.start()

defmodule MicrosoftKeysTest do
  use ExUnit.Case, async: true

  describe "valid?/1" do
    test "accepts valid 10-digit keys" do
      for i <- 0..2 do
        site = :io_lib.format("~3..0B", [i * 111]) |> List.to_string()
        assert MicrosoftKeys.valid?("#{site}-7777777")
      end
    end

    test "rejects 10-digit keys with invalid first digits" do
      for i <- 3..9 do
        site = :io_lib.format("~3..0B", [i]) |> List.to_string()
        refute MicrosoftKeys.valid?("#{site}-7777777")
      end
    end

    test "rejects 10-digit keys with an invalid last digit" do
      refute MicrosoftKeys.valid?("111-7777068")
      refute MicrosoftKeys.valid?("111-7777059")
    end

    test "rejects 10-digit keys with invalid last segment" do
      refute MicrosoftKeys.valid?("111-7777775")
    end

    test "accepts valid OEM keys" do
      assert MicrosoftKeys.valid?("13796-OEM-0134373-37984")
    end

    test "rejects invalid days in OEM keys" do
      refute MicrosoftKeys.valid?("37302-OEM-0683774-44111")
    end

    test "rejects invalid years in OEM keys" do
      refute MicrosoftKeys.valid?("20293-OEM-0670672-93055")
    end

    test "rejects OEM keys without a 0 as the first digit of the 7-digit key" do
      refute MicrosoftKeys.valid?("16796-OEM-4636373-10164")
    end

    test "rejects OEM keys where the 7-digit key isn't divisible by 7" do
      refute MicrosoftKeys.valid?("32301-OEM-0940671-30328")
    end

    test "rejects malformed keys" do
      refute MicrosoftKeys.valid?("abcdefghijklmnop")
    end
  end

  describe "generate_key/1" do
    test "generates a valid ten_digit key" do
      assert MicrosoftKeys.generate_key(:ten_digit) |> MicrosoftKeys.valid?()
    end

    test "generates a valid OEM key" do
      assert MicrosoftKeys.generate_key(:oem) |> MicrosoftKeys.valid?()
    end

    test "generates different ten_digit keys each run" do
      key1 = MicrosoftKeys.generate_key(:ten_digit)
      key2 = MicrosoftKeys.generate_key(:ten_digit)
      refute key1 == key2
    end

    test "generates different oem keys each run" do
      key1 = MicrosoftKeys.generate_key(:oem)
      key2 = MicrosoftKeys.generate_key(:oem)
      refute key1 == key2
    end
  end
end
