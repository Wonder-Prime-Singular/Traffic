import XCTest
import CwlPreconditionTesting
func hasBadInstruction(in block: @escaping () -> Void) -> Bool {
  var reachedPoint1 = false
  var reachedPoint2 = false
  let exception1 = CwlPreconditionTesting.catchBadInstruction {
    reachedPoint1 = true
    block()
    reachedPoint2 = true
  }
  XCTAssert(reachedPoint1)
  XCTAssert(exception1 == nil || !reachedPoint2)
  return exception1 != nil
}
func assertBadInstruction(in block: @escaping () -> Void) -> Void {
  XCTAssertTrue(hasBadInstruction(in: block))
}
func assertNoBadInstruction(in block: @escaping () -> Void) -> Void {
  XCTAssertFalse(hasBadInstruction(in: block))
}
