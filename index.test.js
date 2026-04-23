const { add, subtract, multiply, divide } = require("./index");

describe("Calculator", () => {
  test("add", () => expect(add(2, 3)).toBe(5));
  test("subtract", () => expect(subtract(5, 3)).toBe(2));
  test("multiply", () => expect(multiply(3, 4)).toBe(12));
  test("divide", () => expect(divide(10, 2)).toBe(5));
  test("divide by zero", () => expect(() => divide(1, 0)).toThrow());
});