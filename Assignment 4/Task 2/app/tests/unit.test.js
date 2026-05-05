const { calculateSum, calculateDifference } = require('../index');

describe('Unit Tests for calculator functions', () => {
  test('calculateSum adds two positive numbers correctly', () => {
    expect(calculateSum(2, 3)).toBe(5);
  });

  test('calculateSum adds negative numbers correctly', () => {
    expect(calculateSum(-2, -3)).toBe(-5);
  });

  test('calculateSum handles zero correctly', () => {
    expect(calculateSum(0, 5)).toBe(5);
  });

  test('calculateDifference subtracts correctly', () => {
    expect(calculateDifference(10, 4)).toBe(6);
  });

  test('calculateDifference handles negative results', () => {
    expect(calculateDifference(4, 10)).toBe(-6);
  });
});
