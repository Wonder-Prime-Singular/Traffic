import Traffic
import Foundation
public struct _OperationQueue {
  public let base: OperationQueue
  public init(_ base: OperationQueue) {
    self.base = base
  }
}
extension OperationQueue {
  public var trafficOperationQueue: _OperationQueue {
    return .init(self)
  }
}
extension _OperationQueue: _Scheduler {
  /// The scheduler time type used by the operation queue.
  public struct SchedulerTimeType: Strideable, Codable, Hashable {
    /// The interval by which operation queue times advance.
    public struct Stride: ExpressibleByFloatLiteral, Comparable, Equatable, AdditiveArithmetic, Numeric, SignedNumeric, Codable, _SchedulerTimeIntervalConvertible {
      /// The value of this time interval in seconds.
      public let timeInterval: TimeInterval
      public init(_ timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
      }
      /// If created via floating point literal, the value is converted to nanoseconds via multiplication.
      public typealias FloatLiteralType = TimeInterval
      /// Creates a dispatch queue time interval from a floating-point seconds value.
      ///
      /// - Parameter value: The number of seconds, as a `Double`.
      public init(floatLiteral value: TimeInterval) {
        self = .seconds(value)
      }
      /// A type that represents an integer literal.
      ///
      /// The standard library integer and floating-point types are all valid types
      /// for `IntegerLiteralType`.
      public typealias IntegerLiteralType = TimeInterval
      /// Creates a dispatch queue time interval from an integer seconds value.
      ///
      /// - Parameter value: The number of seconds, as an `Int`.
      public init(integerLiteral value: TimeInterval) {
        self = .seconds(value)
      }
      public static func < (lhs: Stride, rhs: Stride) -> Bool {
        return lhs.timeInterval < rhs.timeInterval
      }
      public static func == (lhs: Stride, rhs: Stride) -> Bool {
        return lhs.timeInterval == rhs.timeInterval
      }
      public static func + (lhs: Stride, rhs: Stride) -> Stride {
        return .init(lhs.timeInterval + rhs.timeInterval)
      }
      public static func += (lhs: inout Stride, rhs: Stride) {
        lhs = lhs + rhs
      }
      public static func - (lhs: Stride, rhs: Stride) -> Stride {
        return .init(lhs.timeInterval - rhs.timeInterval)
      }
      public static func -= (lhs: inout Stride, rhs: Stride) {
        lhs = lhs - rhs
      }
      public init?<T>(exactly source: T) where T: BinaryInteger {
        let value: Int = numericCast(source)
        self = .init(TimeInterval(value))
      }
      /// A type that can represent the absolute value of any possible value of the
      /// conforming type.
      public typealias Magnitude = TimeInterval
      /// The value of this time interval in seconds.
      public var magnitude: TimeInterval {
        return timeInterval
      }
      public static func * (lhs: Stride, rhs: Stride) -> Stride {
        return .init(lhs.timeInterval * rhs.timeInterval)
      }
      public static func *= (lhs: inout Stride, rhs: Stride) {
        lhs = lhs * rhs
      }
      public static func seconds(_ s: Int) -> Stride {
        return .init(TimeInterval(s))
      }
      public static func seconds(_ s: Double) -> Stride {
        return .init(s)
      }
      public static func milliseconds(_ ms: Int) -> Stride {
        return .init(TimeInterval(ms) / TimeInterval(1000))
      }
      public static func microseconds(_ us: Int) -> Stride {
        return .init(TimeInterval(us) / TimeInterval(1_000_000))
      }
      public static func nanoseconds(_ ns: Int) -> Stride {
        return .init(TimeInterval(ns) / TimeInterval(1_000_000_000))
      }
    }
    /// The date represented by this type.
    public var date: Date
    /// Initializes a operation queue scheduler time with the given date.
    ///
    /// - Parameter date: The date to represent.
    public init(_ date: Date) {
      self.date = date
    }
    /// Returns the distance to another operation queue scheduler time.
    ///
    /// - Parameter other: Another operation queue time.
    /// - Returns: The time interval between this time and the provided time.
    public func distance(to other: SchedulerTimeType) -> Stride {
      let d = date.timeIntervalSince(other.date)
      return .seconds(d)
    }
    /// Returns a operation queue scheduler time calculated by advancing this instance’s time by the given interval.
    ///
    /// - Parameter n: A time interval to advance.
    /// - Returns: A operation queue time advanced by the given interval from this instance’s time.
    public func advanced(by n: Stride) -> SchedulerTimeType {
      return .init(date.addingTimeInterval(n.timeInterval))
    }
  }
  /// Options that affect the operation of the operation queue scheduler.
  public struct SchedulerOptions {}
  /// Performs the action at the next possible opportunity.
  public func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
    base.addOperation(action)
  }
  /// Performs the action at some time after the specified date.
  public func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
    let target = TimerTarget(action: action)
    let timer = Timer(fireAt: Date.distantFuture, interval: 0, target: target, selector: #selector(TimerTarget.fire(_:)), userInfo: nil, repeats: false)
    timer.tolerance = tolerance.timeInterval
    let fire = BlockOperation(block: timer.fire)
    let selector: Selector = #selector(OperationQueue.addOperation(_:) as (OperationQueue) -> (Operation) -> Void)
    base.perform(selector, with: fire, afterDelay: date.distance(to: now).timeInterval)
  }
  /// Performs the action at some time after the specified date, at the specified
  /// frequency, optionally taking into account tolerance if possible.
  public func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> _Cancellable {
    let target = TimerTarget(action: action)
    let timer = Timer(fireAt: Date.distantFuture, interval: interval.timeInterval, target: target, selector: #selector(TimerTarget.fire(_:)), userInfo: nil, repeats: true)
    timer.tolerance = tolerance.timeInterval
    let fire = BlockOperation(block: timer.fire)
    let selector: Selector = #selector(OperationQueue.addOperation(_:) as (OperationQueue) -> (Operation) -> Void)
    base.perform(selector, with: fire, afterDelay: date.distance(to: now).timeInterval)
    return _AnyCancellable({
      NSObject.cancelPreviousPerformRequests(withTarget: self.base, selector: selector, object: fire)
      target.cancel()
      if timer.isValid {
        timer.invalidate()
      }
    })
  }
  /// Returns this scheduler's definition of the current moment in time.
  public var now: SchedulerTimeType {
    return .init(.init())
  }
  /// Returns the minimum tolerance allowed by the scheduler.
  public var minimumTolerance: SchedulerTimeType.Stride {
    return .zero
  }
}
