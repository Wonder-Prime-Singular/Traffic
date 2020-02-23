import XCTest
@testable import Traffic
import Combine
@available(OSX 10.15, *)
enum Event<Element: Equatable>: Equatable, CustomStringConvertible, CustomDebugStringConvertible {
  case error
  case completed
  case element(Element)
  
  init<Failure>(_ completion: _Subscribers.Completion<Failure>) {
    switch completion {
    case .failure:
      self = .error
    case .finished:
      self = .completed
    }
  }
  
  init<Failure>(_ completion: Subscribers.Completion<Failure>) {
    switch completion {
    case .failure:
      self = .error
    case .finished:
      self = .completed
    }
  }
  
  init(_ element: Element) {
    self = .element(element)
  }
  
  var description: String {
    switch self {
    case .completed:
      return "C"
    case .error:
      return "E"
    case .element(let value):
      return "\(value)"
    }
  }
  var debugDescription: String {
    return description
  }
}

