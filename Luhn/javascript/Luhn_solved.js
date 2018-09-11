const luhn = function(cc) {
  const digits = cc
    .toString()
    .split("")
    .reverse()
    .map(d => parseInt(d));

  let csum = 0;
  for (let idx = 0; idx < digits.length; idx += 2) {
    const [odd=0, even=0] = digits.slice(idx, idx + 2)
    let double = even * 2
    if (double > 9) { double -= 9 }
    csum += double + odd
  }
  return (csum % 10) === 0
}

// DO NOT EDIT BELOW THIS LINE
console.assert(luhn(49927398716), "49927398716 should be valid");
console.assert(luhn(1234567812345670), "1234567812345670 should be valid");
console.assert(!luhn(49927398717), "49927398717 should be invalid");
console.assert(!luhn(1234567812345678), "1234567812345678 should be invalid");
