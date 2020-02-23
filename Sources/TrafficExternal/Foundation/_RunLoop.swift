import Traffic
import Foundation
public struct _RunLoop {
  public let base: RunLoop
  public init(_ base: RunLoop) {
    self.base = base
  }
}
extension RunLoop {
  public var trafficRunLoop: _RunLoop {
    return .init(self)
  }
}
extension _RunLoop: _Scheduler {
  /// The scheduler time type used by the run loop.
  public struct SchedulerTimeType: Strideable, Codable, Hashable {
    /// The interval by which run loop times advance.
    public struct Stride: ExpressibleByFloatLiteral, Comparable, Equatable, AdditiveArithmetic, Numeric, SignedNumeric, Codable, _SchedulerTimeIntervalConvertible {
      /// The value of this time interval in seconds.
      public let timeInterval: TimeInterval
      public init(_ timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
      }
      public typealias FloatLiteralType = TimeInterval
      public init(floatLiteral value: TimeInterval) {
        self = .seconds(value)
      }
      public typealias IntegerLiteralType = TimeInterval
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
      public init?<T>(exactly: T) where T: BinaryInteger {
        return nil
      }
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
    /// Initializes a run loop scheduler time with the given date.
    ///
    /// - Parameter date: The date to represent.
    public init(_ date: Date) {
      self.date = date
    }
    /// Returns the distance to another run loop scheduler time.
    ///
    /// - Parameter other: Another dispatch queue time.
    /// - Returns: The time interval between this time and the provided time.
    public func distance(to other: SchedulerTimeType) -> Stride {
      let d = date.timeIntervalSince(other.date)
      return .seconds(d)
    }
    /// Returns a run loop scheduler time calculated by advancing this instance’s time by the given interval.
    ///
    /// - Parameter n: A time interval to advance.
    /// - Returns: A dispatch queue time advanced by the given interval from this instance’s time.
    public func advanced(by n: Stride) -> SchedulerTimeType {
      return .init(date.addingTimeInterval(n.timeInterval))
    }
  }
  /// Options that affect the operation of the operation queue scheduler.
  public struct SchedulerOptions {
    public var mode: RunLoop.Mode
    public init(mode: RunLoop.Mode = .default) {
      self.mode = mode
    }
  }
  /// Performs the action at the next possible opportunity.
  public func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
    let target = TimerTarget(action: action)
    let timer = Timer(fireAt: Date.distantFuture, interval: 0, target: target, selector: #selector(TimerTarget.fire(_:)), userInfo: nil, repeats: false)
    base.add(timer, forMode: options?.mode ?? .default)
    timer.fire()
  }
  /// Performs the action at some time after the specified date.
  public func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
    let target = TimerTarget(action: action)
    let timer = Timer(fireAt: date.date, interval: 0, target: target, selector: #selector(TimerTarget.fire(_:)), userInfo: nil, repeats: false)
    timer.tolerance = tolerance.timeInterval
    base.add(timer, forMode: options?.mode ?? .default)
  }
  /// Performs the action at some time after the specified date, at the specified
  /// frequency, optionally taking into account tolerance if possible.
  public func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> _Cancellable {
    let target = TimerTarget(action: action)
    let timer = Timer(fireAt: date.date, interval: interval.timeInterval, target: target, selector: #selector(TimerTarget.fire(_:)), userInfo: nil, repeats: true)
    timer.tolerance = tolerance.timeInterval
    base.add(timer, forMode: options?.mode ?? .default)
    return _AnyCancellable({
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
