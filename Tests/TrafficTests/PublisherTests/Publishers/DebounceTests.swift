import XCTest
@testable import Traffic
@testable import TrafficExternal
import Combine
@available(OSX 10.15, *)
final class DebounceTests: XCTestCase, TestCaseProtocol {
typealias Element = String

  func testScheduler<S1: _Scheduler, S2: Scheduler>(scheduler1: S1, scheduler2: S2, interval: Double, error: Double) -> Void {
    let s1 = _PassthroughSubject<String, Error>()
    let s2 = PassthroughSubject<String, Error>()
    sink(s1.debounce(for: .seconds(interval), scheduler: scheduler1),
         s2.debounce(for: .seconds(interval), scheduler: scheduler2))
    let e = XCTestExpectation(description: "debounce")
    DispatchQueue.global().async {
      var x = 0
      while x < 20  {
        s1.send(x.description)
        s2.send(x.description)
        x += 1
        Thread.sleep(forTimeInterval: interval + error * (Bool.random() ? 1.0 : -1.0))
      }
      self.checkEqualAll()
      e.fulfill()
    }
    self.wait(for: [e], timeout: 20 * (interval + error))
  }
  func testRunLoop() -> Void {
    func testRunLoopS(interval: Double, error: Double) {
      testScheduler(scheduler1: RunLoop.main.trafficRunLoop, scheduler2: RunLoop.main, interval: interval, error: error)
    }
    testRunLoopS(interval: 0.05, error: 0.01)
  }
  func testOperationQueue() -> Void {
    func testOperationQueueS(interval: Double, error: Double) -> Void {
      testScheduler(scheduler1: OperationQueue.main.trafficOperationQueue, scheduler2: OperationQueue.main, interval: interval, error: error)
    }
    testOperationQueueS(interval: 0.05, error: 0.01)
  }
  func testDispatchQueue() -> Void {
    func testDispatchQueueS(interval: Double, error: Double) -> Void {
      testScheduler(scheduler1: DispatchQueue.main.trafficDispatchQueue, scheduler2: DispatchQueue.main, interval: interval, error: error)
    }
    testDispatchQueueS(interval: 0.05, error: 0.01)
  }
}
