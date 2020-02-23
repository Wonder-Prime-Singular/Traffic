import Traffic
import Foundation
public struct NSObjectProtocolBox<Subject: NSObject> {
  public let base: Subject
  public init(_ base: Subject) {
    self.base = base
  }
}
extension NSObjectProtocol where Self: NSObject {
  public var trafficObject: NSObjectProtocolBox<Self> {
    return .init(self)
  }
}
public enum _NSObject {
  /// A publisher that emits events when the value of a KVO-compliant property changes.
  public struct KeyValueObservingPublisher<Subject: NSObject, Value>: _Publisher {
    public typealias Output = Value
    public typealias Failure = Never
    public let object: Subject
    public let keyPath: KeyPath<Subject, Value>
    public let options: NSKeyValueObservingOptions
    public init(object: Subject, keyPath: KeyPath<Subject, Value>, options: NSKeyValueObservingOptions) {
      self.object = object
      self.keyPath = keyPath
      self.options = options
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let leading = _Subscriptions.Leading.NSObject<Subject, Downstream>(publisher: self, downstream: subscriber)
      subscriber.receive(subscription: leading)
    }
  }
}
extension NSObjectProtocolBox {
  public func publisher<Value>(for keyPath: KeyPath<Subject, Value>, options: NSKeyValueObservingOptions = [.initial, .new]) -> _NSObject.KeyValueObservingPublisher<Subject, Value> {
    return .init(object: base, keyPath: keyPath, options: options)
  }
}
private extension _Subscriptions.Leading {
  class NSObject<Subject: Foundation.NSObject, Downstream: _Subscriber>: _Subscriptions.Leading.Simple<Downstream> where Downstream.Failure == Never {
    weak var object: Subject?
    typealias Value = Downstream.Input
    let keyPath: KeyPath<Subject, Value>
    let options: NSKeyValueObservingOptions
    var observation: NSKeyValueObservation?
    var subscribed: Bool = false
    init(publisher: _NSObject.KeyValueObservingPublisher<Subject, Downstream.Input>, downstream: Downstream) {
      self.object = publisher.object
      self.keyPath = publisher.keyPath
      self.options = publisher.options
      super.init(downstream: downstream)
      observation = object?.observe(keyPath, options: options) { [weak self] (object, _) in
        guard let self = self else {
          return
        }
        guard self.subscribed else {
          return
        }
        _ = self.downstream?.receive(object[keyPath: self.keyPath])
      }
    }
    override func cancel() {
      guard !isCancelled else {
        return
      }
      isCancelled = true
      observation?.invalidate()
      observation = nil
      downstream = nil
    }
    override func request(_ demand: _Subscribers.Demand) {
      guard !isCancelled else {
        return
      }
      self.subscribed = true
      if let object = self.object {
        _ = downstream?.receive(object[keyPath: keyPath])
      }
    }
    override var description: String {
      return "KVOSubscription"
    }
  }
}
