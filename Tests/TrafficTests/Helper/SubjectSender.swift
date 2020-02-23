import Traffic
import Combine
import Foundation
enum ElementEventTiming {
  case random(ClosedRange<Double>)
  case interval(Double)
}
@available(OSX 10.15, *)
class ElementSender<S1: _Subject, S2: Subject> where S1.Output == S2.Output, S1.Failure == S2.Failure {
  typealias Output = S1.Output
  typealias Failure = S1.Failure
  let subject1: S1
  let subject2: S2
  init(publisher1: S1, publisher2: S2) {
    self.subject1 = publisher1
    self.subject2 = publisher2
  }
  func forever(_ body: @escaping (Int) -> (output: Output?, completion: _Subscribers.Completion<Failure>?), timing: ElementEventTiming) -> Void {
    fire(sequence: 0..., body, timing: timing)
  }
  func finite(length: Int, _ body: @escaping (Int) -> (output: Output?, completion: _Subscribers.Completion<Failure>?), timing: ElementEventTiming) -> Void {
    fire(sequence: 0..<length, body, timing: timing)
  }
  func sequence(output: Output..., completion: _Subscribers.Completion<Failure>, timing: ElementEventTiming) -> Void {
    self.sequence(outputs: output, completion: completion, timing: timing)
  }
  func sequence(outputs: [Output], completion: _Subscribers.Completion<Failure>, timing: ElementEventTiming) -> Void {
    fire(sequence: 0..<(outputs.count + 1), { (index) in
      if index < outputs.count {
        return (outputs[index], nil)
      }
      return (nil, completion)
    }, timing: timing)
  }
  private func fire<S: Sequence>(sequence: S, _ body: @escaping (Int) -> (output: Output?, completion: _Subscribers.Completion<Failure>?), timing: ElementEventTiming) -> Void where S.Element == Int {
    sequence.forEach({ (index) in
      let element = body(index)
      switch timing {
      case .interval(let d):
        Thread.sleep(forTimeInterval: d)
      case .random(let range):
        Thread.sleep(forTimeInterval: Double.random(in: range))
      }
      element.output.map(subject1.send(_:))
      element.output.map(subject2.send(_:))
      element.completion.map {
        switch $0 {
        case .failure(let error):
          subject1.send(completion: .failure(error))
          subject2.send(completion: .failure(error))
        case .finished:
          subject1.send(completion: .finished)
          subject2.send(completion: .finished)
        }
      }
    })
  }
}
@available(OSX 10.15, *)
class CurrentValueSender<Output, Failure: Error>: ElementSender<_CurrentValueSubject<Output, Failure>, CurrentValueSubject<Output, Failure>> {
  convenience init(value: Output) {
    self.init(publisher1: _CurrentValueSubject<Output, Failure>(value), publisher2: CurrentValueSubject<Output, Failure>(value))
  }
}
@available(OSX 10.15, *)
class PassthroughSender<Output, Failure: Error>: ElementSender<_PassthroughSubject<Output, Failure>, PassthroughSubject<Output, Failure>> {
  convenience init() {
    self.init(publisher1: _PassthroughSubject<Output, Failure>(), publisher2: PassthroughSubject<Output, Failure>())
  }
}
