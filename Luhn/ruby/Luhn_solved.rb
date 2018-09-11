def valid?(cc)
  csum = 0
  cc.digits.each_slice(2) do |odd, even|
    double = even.to_i * 2
    double -= 9 if double > 9
    csum += double + odd
  end
  (csum % 10).zero?
end

require 'minitest/autorun'
class TestLuhn < Minitest::Test
  def test_49927398716
    assert valid?(49_927_398_716)
  end

  def test_49927398717
    refute valid?(49_927_398_717)
  end

  def test_1234567812345678
    refute valid?(1_234_567_812_345_678)
  end

  def test_1234567812345670
    assert valid?(1_234_567_812_345_670)
  end
end
