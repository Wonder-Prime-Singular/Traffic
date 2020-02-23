/// A scheduler for performing synchronous actions.
///
/// You can use this scheduler for immediate actions. If you attempt to schedule actions after a specific date, the scheduler ignores the date and executes synchronously.
public struct _ImmediateScheduler: _Scheduler {
  /// The time type used by the immediate scheduler.
  public struct SchedulerTimeType: Strideable {
    /// The increment by which the immediate scheduler counts time.
    public struct Stride: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, Comparable, Equatable, AdditiveArithmetic, Numeric, SignedNumeric, Codable, _SchedulerTimeIntervalConvertible {
      public init() {
      }
      public typealias FloatLiteralType = Double
      public init(floatLiteral value: Double) {
        self = .seconds(value)
      }
      public typealias IntegerLiteralType = Int
      public init(integerLiteral value: Int) {
        self = .seconds(value)
      }
      public static func < (lhs: Stride, rhs: Stride) -> Bool {
        return false
      }
      public static func + (lhs: Stride, rhs: Stride) -> Stride {
        return .init()
      }
      public static func += (lhs: inout Stride, rhs: Stride) {
        lhs = lhs + rhs
      }
      public static func - (lhs: Stride, rhs: Stride) -> Stride {
        return .init()
      }
      public static func -= (lhs: inout Stride, rhs: Stride) {
        lhs = lhs - rhs
      }
      public init?<T: BinaryInteger>(exactly source: T) {
        self = .init()
      }
      public typealias Magnitude = Int
      public var magnitude: Int {
        return 0
      }
      public static func * (lhs: Stride, rhs: Stride) -> Stride {
        return .init()
      }
      public static func *= (lhs: inout Stride, rhs: Stride) {
        lhs = lhs * rhs
      }
      public static func seconds(_ s: Int) -> Stride {
        return .init()
      }
      public static func seconds(_ s: Double) -> Stride {
        return .init()
      }
      public static func milliseconds(_ ms: Int) -> Stride {
        return .init()
      }
      public static func microseconds(_ us: Int) -> Stride {
        return .init()
      }
      public static func nanoseconds(_ ns: Int) -> Stride {
        return .init()
      }
    }
    /// Returns the distance to another immediate scheduler time; this distance is always `0` in the context of an immediate scheduler.
    ///
    /// - Parameter other: The other scheduler time.
    /// - Returns: `0`, as a `Stride`.
    public func distance(to other: SchedulerTimeType) -> Stride {
      return .init()
    }
    /// Advances the time by the specified amount; this is meaningless in the context of an immediate scheduler.
    ///
    /// - Parameter n: The amount to advance by. The `_ImmediateScheduler` ignores this value.
    /// - Returns: An empty `SchedulerTimeType`.
    public func advanced(by n: Stride) -> SchedulerTimeType {
      return self
    }
  }
  /// A type that defines options accepted by the scheduler.
  ///
  /// This type is freely definable by each `Scheduler`. Typically, operations that take a `Scheduler` parameter will also take `SchedulerOptions`.
  public typealias SchedulerOptions = Never
  /// The shared instance of the immediate scheduler.
  ///
  /// You cannot create instances of the immediate scheduler yourself. Use only the shared instance.
  public static let shared: _ImmediateScheduler = _ImmediateScheduler()
  /// Performs the action at the next possible opportunity.
  public func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
    action()
  }
  /// Returns this scheduler's definition of the current moment in time.
  public var now: SchedulerTimeType {
    return .init()
  }
  /// Returns the minimum tolerance allowed by the scheduler.
  public var minimumTolerance: SchedulerTimeType.Stride {
    return .init()
  }
  /// Performs the action at some time after the specified date.
  public func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
    action()
  }
  /// Performs the action at some time after the specified date, at the specified
  /// frequency, optionally taking into account tolerance if possible.
  public func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> _Cancellable {
    action()
    return _AnyCancellable({})
  }
}
