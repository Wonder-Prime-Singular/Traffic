import XCTest
@testable import Traffic
import Combine
@available(OSX 10.15, *)
final class FlatMapTests: XCTestCase, TestCaseProtocol {

  override func setUp() {
    super.setUp()
    self.continueAfterFailure = false
  }
  typealias Element = Int

  var cancellableBag: Set<_AnyCancellable> = []
  let array = [1, 2, 3, 4, 5]
  struct AA: Equatable {
    let output: [Int]
    let completion: _Subscribers.Completion<Error>
    init(output: [Int], completion: _Subscribers.Completion<Error>) {
      self.output = output
      self.completion = completion
    }
    static func == (lhs: AA, rhs: AA) -> Bool {
      return lhs.output == rhs.output && lhs.completion.isFinished == rhs.completion.isFinished
    }
    var _record: _Record<Int, Error> {
      _Record(output: output, completion: completion)
    }
    var record: Record<Int, Error> {
      Record(output: output, completion: {
        switch completion {
        case .finished:
          return Subscribers.Completion.finished
        case .failure(let error):
          return Subscribers.Completion.failure(error)
        }
      }())
    }
  }
  struct A {
    let output: [AA]
    let completion: _Subscribers.Completion<Error>
    init(output: [AA], completion: _Subscribers.Completion<Error>) {
      self.output = output
      self.completion = completion
    }
  }
  var recordingsOutFailureInFailure_1: A {
    return A(output: [AA(output: array.map({ $0 * 1 }), completion: .finished),
                      AA(output: array.map({ $0 * 2 }), completion: .failure(someError)),
                      AA(output: array.map({ $0 * 3 }), completion: .finished)],
             completion:.failure(someError))
  }

  var recordingsOutFailureInSuccess_2: A {
    return A(output: [AA(output: array.map({ $0 * 1 }), completion: .finished),
                      AA(output: array.map({ $0 * 2 }), completion: .finished),
                      AA(output: array.map({ $0 * 3 }), completion: .finished)],
             completion: .failure(someError))
  }

  var recordingsOutSuccessInFailure_3: A {
    return A(output: [AA(output: array.map({ $0 * 1 }), completion: .finished),
                      AA(output: array.map({ $0 * 2 }), completion: .failure(someError)),
                      AA(output: array.map({ $0 * 3 }), completion: .finished)],
             completion: .finished)
  }

  var recordingsOutSuccessInSuccess_4: A {
    return A(output: [AA(output: array.map({ $0 * 1 }), completion: .finished),
                      AA(output: array.map({ $0 * 2 }), completion: .finished),
                      AA(output: array.map({ $0 * 3 }), completion: .finished)],
             completion: .finished)
  }

  func testPublisher1() -> Void {
    self.testWithRecording(recordingsOutFailureInFailure_1, delay: true)
  }

  func testPublisher2() -> Void {
    self.testWithRecording(recordingsOutFailureInFailure_1, delay: false)
  }

  func testPublisher3() -> Void {
    self.testWithRecording(recordingsOutFailureInSuccess_2, delay: true)
  }

  func testPublisher4() -> Void {
    self.testWithRecording(recordingsOutFailureInSuccess_2, delay: false)
  }

  func testPublisher5() -> Void {
    self.testWithRecording(recordingsOutSuccessInFailure_3, delay: true)
  }

  func testPublisher6() -> Void {
    self.testWithRecording(recordingsOutSuccessInFailure_3, delay: false)
  }

  func testPublisher7() -> Void {
    self.testWithRecording(recordingsOutSuccessInSuccess_4, delay: true)
  }

  func testPublisher8() -> Void {
    self.testWithRecording(recordingsOutSuccessInSuccess_4, delay: false)
  }

  func testWithRecording(_ recordings: A, delay: Bool) -> Void {
    testWithRecording(recordings, delay: delay, max: nil)
//    testWithRecording(recordings, delay: delay, max: 1)
  }

  func ran() -> String {
    return (0..<5).map({ _ in Int.random(in: 0...9) }).map({ String.init(describing: $0) }).joined()
  }

  func testWithRecording(_ recordings: A, delay: Bool, max: Int?) -> Void {
    let e = XCTestExpectation()
    let queue = DispatchQueue(label: "delay", qos: .utility)
    var qqq = 0
    var www = 0
    self.testMany(elements: recordings.output, completion: recordings.completion, transform1: {
      return $0.flatMap(maxPublishers: max == nil ? .unlimited : .max(max!), { (a) -> _AnyPublisher<Int, Error> in
        let recording = a._record
        if delay {
          qqq += 1
          return recording
            .delay(for: .seconds(1), scheduler: queue.trafficDispatchQueue)
            .eraseToAnyPublisher()
        } else {
          return recording.eraseToAnyPublisher()
        }
      })
      .print("TRF")
    }, transform2: {
      return $0.flatMap(maxPublishers: max == nil ? .unlimited : .max(max!), { (a) -> AnyPublisher<Int, Error> in
        let recording = a.record
        if delay {
          www += 1
          return recording
            .delay(for: .seconds(1), scheduler: queue)
            .eraseToAnyPublisher()
        } else {
          return recording.eraseToAnyPublisher()
        }
      })
        .print("CMB")
    }) {
      e.fulfill()
    }
    self.wait(for: [e], timeout: 100)
  }
}
