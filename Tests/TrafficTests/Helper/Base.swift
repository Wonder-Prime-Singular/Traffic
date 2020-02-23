//
//  File.swift
//  
//
//  Created by Felicity on 2/23/20.
//
import ObjectiveC.runtime
import XCTest
import Combine
@testable import Traffic
@testable import TrafficExternal

@available(OSX 10.15, *)
class TestData<Element: Equatable> {
  var cancellables: [Any] = []
  var myResults: [Event<Element>] = []
  var combineResults: [Event<Element>] = []
  var myReturnedDemand: [_Subscribers.Demand] = []
  var combineReturnedDemand: [Subscribers.Demand] = []
}

@available(OSX 10.15, *)
protocol TestCaseProtocol {
  associatedtype Element: Equatable
  var data: TestData<Element> { get }
}
private var dataKey: String = "H8dhQH21bidbiqsdu"
@available(OSX 10.15, *)
extension TestCaseProtocol where Self: XCTestCase {

  var data: TestData<Element> {
    if let d = objc_getAssociatedObject(self, &dataKey) as? TestData<Element> {
    return d
    }
    let d = TestData<Element>()
    objc_setAssociatedObject(self, &dataKey, d, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return d
  }


  func cancelAll() {
    data.cancellables.removeAll()
  }
  

  func deallocate() {
    data.cancellables.removeAll()
    data.myResults.removeAll()
    data.combineResults.removeAll()
  }


  func sink<P: _Publisher>(_ p: P, _ completionHandler: (() -> Void)?) -> Void where P.Output == Element {
    let s = _Subscribers.Sink<Element, P.Failure>(receiveCompletion: { (completion) in
      self.data.myResults.append(.init(completion))
    }) { (value) in
      self.data.myResults.append(.init(value))
    }
    let any = _AnySubscriber<Element, P.Failure>(receiveSubscription: { (subscription) in
      s.receive(subscription: subscription)
    }, receiveValue: { (value) in
      let d = s.receive(value)
      self.data.myReturnedDemand.append(d)
      return d
    }) { (completion) in
      s.receive(completion: completion)
      completionHandler?()
    }
    p.subscribe(any)
    data.cancellables.append(_AnyCancellable(s))
  }

  func sink<P: Publisher>(_ p: P, _ completionHandler: (() -> Void)?) -> Void where P.Output == Element {
    let s = Subscribers.Sink<Element, P.Failure>(receiveCompletion: { (completion) in
      self.data.combineResults.append(.init(completion))
    }) { (value) in
      self.data.combineResults.append(.init(value))
    }
    let any = AnySubscriber<Element, P.Failure>(receiveSubscription: { (subscription) in
      s.receive(subscription: subscription)
    }, receiveValue: { (value) in
      let d = s.receive(value)
      self.data.combineReturnedDemand.append(d)
      return d
    }) { (completion) in
      s.receive(completion: completion)
      completionHandler?()
    }
    p.subscribe(any)
    data.cancellables.append(AnyCancellable(s))
  }

  func sink<P1: _Publisher, P2: Publisher>(_ p1: P1, _ p2: P2, _ completionHandler: (() -> Void)? = nil) -> Void where P1.Output == Element, P2.Output == Element {
    let group = Group()
    group.completionHandler = completionHandler
    sink(p1, {
      group.setCompleted(1)
    })
    sink(p2, {
      group.setCompleted(2)
    })
    group.setCondition([1, 2])
  }
  @usableFromInline
  func checkEqualReturnedDemand() {
    zip(data.myReturnedDemand, data.combineReturnedDemand).forEach({
      XCTAssert($0.0 == $0.1)
    })
  }
  @usableFromInline
  func checkEqualElements(file: StaticString = #file, line: UInt = #line, message: String = "") {
    XCTAssertEqual(data.myResults, data.combineResults, message, file: file, line: line)
  }
  @usableFromInline
  func checkEqualAll(file: StaticString = #file, line: UInt = #line, message: String = "") {
    checkEqualElements(file: file, line: line, message: message)
    checkEqualReturnedDemand()
    deallocate()
  }
  @usableFromInline
  func testSequence<E: Equatable, P1: _Publisher, P2: Publisher>(file: StaticString = #file, line: UInt = #line, elements: [E], completion: _Subscribers.Completion<Error>,  transform1: @escaping (_AnyPublisher<E, Error>) -> P1, transform2: @escaping (AnyPublisher<E, Error>) -> P2, _ completionHandler0: (() -> Void)? = nil) where P1.Output == Element, P2.Output == Element {
    let isEmpty = elements.isEmpty
    func sequence(_ completionHandler: (() -> Void)?) {
      let sequence1 = _Publishers.Sequence<[E], Swift.Error>(sequence: elements)
      let sequence2 = Publishers.Sequence<[E], Swift.Error>(sequence: elements)
      sink(transform1(_AnyPublisher(sequence1)),
           transform2(AnyPublisher(sequence2)),
           { self.checkEqualAll(file: file, line: line, message: "sequence"); completionHandler?() })
    }
    func just(_ completionHandler: (() -> Void)?) {
      if !isEmpty {
        let just1 = _Just(elements[0])
        let just2 = Just(elements[0])
        sink(transform1(_AnyPublisher(just1.setFailureType(to: Error.self))),
             transform2(AnyPublisher(just2.setFailureType(to: Error.self))),
             { self.checkEqualAll(file: file, line: line, message: "just"); completionHandler?() })
      } else {
        completionHandler?()
      }
    }
    func subject(_ completionHandler: (() -> Void)?) {
      let subjectSender = ElementSender(publisher1: _PassthroughSubject<E, Error>(), publisher2: PassthroughSubject<E, Error>())
      sink(transform1(_AnyPublisher(subjectSender.subject1)),
           transform2(AnyPublisher(subjectSender.subject2)),
           { self.checkEqualAll(file: file, line: line, message: "subject"); completionHandler?() })
      subjectSender.sequence(outputs: elements, completion: completion, timing: .interval(0))
    }
    sequence {
      just {
        subject(completionHandler0)
      }
    }
  }
}
