import Traffic
import Foundation
public struct _NotificationCenter {
  public let base: NotificationCenter
  public init(_ base: NotificationCenter) {
    self.base = base
  }
}
extension NotificationCenter {
  public var trafficNotificationCenter: _NotificationCenter {
    return .init(self)
  }
}
extension _NotificationCenter {
  /// A publisher that emits elements when broadcasting notifications.
  public struct Publisher: _Publisher {
    public typealias Output = Notification
    public typealias Failure = Never
    /// The notification center this publisher uses as a source.
    public let center: NotificationCenter
    /// The name of notifications published by this publisher.
    public let name: Notification.Name
    /// The object posting the named notfication.
    public let object: AnyObject?
    /// Creates a publisher that emits events when broadcasting notifications.
    ///
    /// - Parameters:
    ///   - center: The notification center to publish notifications for.
    ///   - name: The name of the notification to publish.
    ///   - object: The object posting the named notfication. If `nil`, the publisher emits elements for any object producing a notification with the given name.
    public init(center: NotificationCenter, name: Notification.Name, object: AnyObject? = nil) {
      self.center = center
      self.name = name
      self.object = object
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      let leading = _Subscriptions.Leading.NotificationCenter(publisher: self, downstream: subscriber)
      subscriber.receive(subscription: leading)
    }
  }
  /// Returns a publisher that emits events when broadcasting notifications.
  ///
  /// - Parameters:
  ///   - name: The name of the notification to publish.
  ///   - object: The object posting the named notfication. If `nil`, the publisher emits elements for any object producing a notification with the given name.
  /// - Returns: A publisher that emits events when broadcasting notifications.
  public func publisher(for name: Notification.Name, object: AnyObject? = nil) -> _NotificationCenter.Publisher {
    return .init(center: base, name: name, object: object)
  }
}
private extension _Subscriptions.Leading {
  class NotificationCenter<Downstream: _Subscriber>: _Subscriptions.Leading.Base<_NotificationCenter.Publisher, Downstream> where Downstream.Input == Notification, Downstream.Failure == Never {
    var observer: NSObjectProtocol?
    override func cancel() {
      guard !isCancelled else {
        return
      }
      observer.map(publisher.center.removeObserver(_:))
      downstream = nil
    }
    override func request(_ demand: _Subscribers.Demand) {
      guard !isCancelled else {
        return
      }
      if observer == nil {
        observer = publisher.center.addObserver(forName: publisher.name, object: publisher.object, queue: nil) { (note) in
          _ = self.downstream?.receive(note)
        }
      }
    }
    override var description: String {
      return "NotificationCenter Observer"
    }
  }
}
