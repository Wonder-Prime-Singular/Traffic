// MARK: Operation
func add(a: Int, b: Int) -> Int {
  return a + b
}
func add_throws_conditionally(a: Int, b: Int) throws -> Int {
  if a > 2 {
    throw someError
  }
  return a + b
}
func add_throws_unconditionally(a: Int, b: Int) throws -> Int {
  throw someError
}
// MARK: Judge
func judge_true(a: Int) -> Bool {
  return true
}
func judge_false(a: Int) -> Bool {
  return false
}
func judge_depend(a: Int) -> Bool {
  return a > 2
}
func judge_throws_conditionally(a: Int) throws -> Bool {
  if a > 2 {
    throw someError
  }
  return true
}
func judge_throws_unconditionally(a: Int) throws -> Bool {
  throw someError
}
// MARK: Compare
func compare_ascending(a: Int, b: Int) -> Bool {
  return a < b
}
func compare_disascending(a: Int, b: Int) -> Bool {
  return a > b
}
func compare_throws_ascending(a: Int, b: Int) throws -> Bool {
  if a > 3 {
    throw someError
  }
  return a < b
}
func compare_throws_disascending(a: Int, b: Int) throws -> Bool {
  if a > 3 {
    throw someError
  }
  return a > b
}
func compare_throws_unconditionally(a: Int, b: Int) throws -> Bool {
  throw someError
}
