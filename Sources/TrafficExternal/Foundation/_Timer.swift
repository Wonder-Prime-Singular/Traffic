import Traffic
import Foundation
public struct _Timer {
  public let base: Timer
  public init(_ base: Timer) {
    self.base = base
  }
}
extension Timer {
  public var trafficTimer: _Timer {
    return .init(self)
  }
}
extension _Timer {
  /// A publisher that repeatedly emits the current date on a given interval.
  public final class TimerPublisher: _ConnectablePublisher {
    public typealias Output = Date
    public typealias Failure = Never
    public let interval: TimeInterval
    public let tolerance: TimeInterval?
    public let runLoop: RunLoop
    public let mode: RunLoop.Mode
    public let options: _RunLoop.SchedulerOptions?
    internal let lock: Locking = RecursiveLock()
    var receiveValues: [CombineIdentifier: (Output) -> _Subscribers.Demand] = [:]
    var receiveCompletions: [CombineIdentifier: (_Subscribers.Completion<Failure>) -> Void] = [:]
    /// Creates a publisher that repeatedly emits the current date on the given interval.
    ///
    /// - Parameters:
    ///   - interval: The interval on which to publish events.
    ///   - tolerance: The allowed timing variance when emitting events. Defaults to `nil`, which allows any variance.
    ///   - runLoop: The run loop on which the timer runs.
    ///   - mode: The run loop mode in which to run the timer.
    ///   - options: Scheduler options passed to the timer. Defaults to `nil`.
    public init(interval: TimeInterval, tolerance: TimeInterval? = nil, runLoop: RunLoop, mode: RunLoop.Mode, options: _RunLoop.SchedulerOptions? = nil) {
      self.interval = interval
      self.tolerance = tolerance
      self.runLoop = runLoop
      self.mode = mode
      self.options = options
    }
    public func receive<Downstream: _Subscriber>(subscriber: Downstream) where Downstream.Input == Output, Downstream.Failure == Failure {
      self.lock.withLock {
        let id = subscriber.combineIdentifier
        let leading = _Subscriptions.Leading.Timer(publisher: self, downstream: subscriber)
        receiveValues[id] = { (value) in
          return subscriber.receive(value)
        }
        receiveCompletions[id] = { (completion) in
          subscriber.receive(completion: completion)
        }
        subscriber.receive(subscription: leading)
      }
    }
    /// Connects to the publisher and returns a `Cancellable` instance with which to cancel publishing.
    ///
    /// - Returns: A `Cancellable` instance that can be used to cancel publishing.
    public func connect() -> _Cancellable {
      let _runLoop = _RunLoop(runLoop)
      return _runLoop.schedule(after: _runLoop.now, interval: .init(interval), tolerance: tolerance.map(_RunLoop.SchedulerTimeType.Stride.init(_:)) ?? _runLoop.minimumTolerance, options: .init(mode: mode)) { [weak self] in
        guard let self = self else { return }
        self.lock.withLock {
          self.receiveValues.forEach { (_, receiveValue) in
            _ = receiveValue(Date())
          }
        }
      }
    }
  }
  /// Returns a publisher that repeatedly emits the current date on the given interval.
  ///
  /// - Parameters:
  ///   - interval: The time interval on which to publish events. For example, a value of `0.5` publishes an event approximately every half-second.
  ///   - tolerance: The allowed timing variance when emitting events. Defaults to `nil`, which allows any variance.
  ///   - runLoop: The run loop on which the timer runs.
  ///   - mode: The run loop mode in which to run the timer.
  ///   - options: Scheduler options passed to the timer. Defaults to `nil`.
  /// - Returns: A publisher that repeatedly emits the current date on the given interval.
  public static func publish(every interval: TimeInterval, tolerance: TimeInterval? = nil, on runLoop: RunLoop, in mode: RunLoop.Mode, options: _RunLoop.SchedulerOptions? = nil) -> _Timer.TimerPublisher {
    return .init(interval: interval, tolerance: tolerance, runLoop: runLoop, mode: mode, options: options)
  }
}
private extension _Subscriptions.Leading {
  class Timer<Downstream: _Subscriber>: _Subscriptions.Leading.Base<_Timer.TimerPublisher, Downstream> where Downstream.Input == Date, Downstream.Failure == Never {
    override func cancel() {
      guard let id = downstream?.combineIdentifier else {
        return
      }
      publisher.lock.withLock {
        self.publisher.receiveValues.removeValue(forKey: id)
        self.publisher.receiveCompletions.removeValue(forKey: id)
      }
      downstream = nil
    }
    override func request(_ demand: _Subscribers.Demand) {

    }
    override var description: String {
      return "Timer"
    }
  }
}
