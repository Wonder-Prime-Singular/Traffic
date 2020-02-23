import Traffic
import Dispatch
public struct _DispatchQueue {
  public let base: DispatchQueue
  public init(_ base: DispatchQueue) {
    self.base = base
  }
}
extension DispatchQueue {
  public var trafficDispatchQueue: _DispatchQueue {
    return .init(self)
  }
}
extension _DispatchQueue: _Scheduler {
  /// The scheduler time type used by the dispatch queue.
  public struct SchedulerTimeType: Strideable, Codable, Hashable {
    /// A type that represents the distance between two values.
    public struct Stride: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, Comparable, Equatable, AdditiveArithmetic, Numeric, SignedNumeric, Codable, _SchedulerTimeIntervalConvertible {
      /// A `DispatchTimeInterval` created with the value of this type in nanoseconds.
      public let timeInterval: DispatchTimeInterval
      /// Creates a dispatch queue time interval from the given dispatch time interval.
      ///
      /// - Parameter timeInterval: A dispatch time interval.
      public init(_ timeInterval: DispatchTimeInterval) {
        self.timeInterval = timeInterval
      }
      /// If created via floating point literal, the value is converted to nanoseconds via multiplication.
      public typealias FloatLiteralType = Double
      /// Creates a dispatch queue time interval from a floating-point seconds value.
      ///
      /// - Parameter value: The number of seconds, as a `Double`.
      public init(floatLiteral value: Double) {
        self = .seconds(value)
      }
      /// Nanoseconds, same as DispatchTimeInterval.
      public typealias IntegerLiteralType = Int
      /// Creates a dispatch queue time interval from an integer seconds value.
      ///
      /// - Parameter value: The number of seconds, as an `Int`.
      public init(integerLiteral value: Int) {
        self = .seconds(value)
      }
      public static func < (lhs: Stride, rhs: Stride) -> Bool {
        let now = DispatchTime.now()
        return (now + lhs.timeInterval) < (now + rhs.timeInterval)
      }
      public static func == (lhs: Stride, rhs: Stride) -> Bool {
        return lhs.timeInterval == rhs.timeInterval
      }
      @inlinable
      public static func + (lhs: Stride, rhs: Stride) -> Stride {
        if lhs.timeInterval == .never || rhs.timeInterval == .never {
          return .init(.never)
        }
        let sum = lhs.timeInterval.nanoseconds.addingReportingOverflow(rhs.timeInterval.nanoseconds)
        return .nanoseconds(sum.overflow ? Int.max : sum.partialValue)
      }
      public static func += (lhs: inout Stride, rhs: Stride) {
        lhs = lhs + rhs
      }
      @inlinable
      public static func - (lhs: Stride, rhs: Stride) -> Stride {
        if lhs.timeInterval == .never {
          return .init(.never)
        }
        if rhs.timeInterval == .never {
          return .seconds(0)
        }
        let value = lhs.timeInterval.nanoseconds.subtractingReportingOverflow(rhs.timeInterval.nanoseconds)
        return .nanoseconds(value.overflow ? Int.max : value.partialValue)
      }
      public static func -= (lhs: inout Stride, rhs: Stride) {
        lhs = lhs - rhs
      }
      public init?<T>(exactly source: T) where T: BinaryInteger {
        let value: Int = numericCast(source)
        self = .nanoseconds(value)
      }
      public typealias Magnitude = Int
      public var magnitude: Int {
        return timeInterval.nanoseconds
      }
      public static func * (lhs: Stride, rhs: Stride) -> Stride {
        if lhs.timeInterval == .never || rhs.timeInterval == .never {
          return .init(.never)
        }
        let product = lhs.timeInterval.nanoseconds.multipliedReportingOverflow(by: rhs.timeInterval.nanoseconds)
        return .nanoseconds(product.overflow ? Int.max : product.partialValue)
      }
      public static func *= (lhs: inout Stride, rhs: Stride) {
        lhs = lhs * rhs
      }
      struct CodingTimeInterval: Codable {
        internal let unit: String
        internal let value: Int
        internal init(unit: String, value: Int) {
          self.unit = unit
          self.value = value
        }
        internal init(timeInterval: DispatchTimeInterval) throws {
          switch timeInterval {
          case let .seconds(v):      self = CodingTimeInterval(unit: "seconds", value: v)
          case let .milliseconds(v): self = CodingTimeInterval(unit: "milliseconds", value: v)
          case let .microseconds(v): self = CodingTimeInterval(unit: "microseconds", value: v)
          case let .nanoseconds(v):  self = CodingTimeInterval(unit: "nanoseconds", value: v)
          case .never:               self = CodingTimeInterval(unit: "never", value: 0)
          @unknown default:          throw EncodingError.invalidValue(timeInterval, EncodingError.Context(codingPath: [CodingTimeInterval.CodingKeys.unit], debugDescription: "invalidValue"))
          }
        }
        func timeInterval() throws -> DispatchTimeInterval {
          switch self.unit {
          case "seconds":      return .seconds(value)
          case "milliseconds": return .milliseconds(value)
          case "microseconds": return .microseconds(value)
          case "nanoseconds":  return .nanoseconds(value)
          case "never":        return .never
          default:             throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingTimeInterval.CodingKeys.unit], debugDescription: "\(self.unit) not found"))
          }
        }
      }
      public init(from decoder: Decoder) throws {
        let c = try CodingTimeInterval(from: decoder)
        self = .init(try c.timeInterval())
      }
      public func encode(to encoder: Encoder) throws {
        let c = try CodingTimeInterval(timeInterval: self.timeInterval)
        try c.encode(to: encoder)
      }
      public static func seconds(_ s: Int) -> Stride {
        return .init(.seconds(s))
      }
      public static func seconds(_ s: Double) -> Stride {
        return .init(.nanoseconds(Int(s * Double(NSEC_PER_SEC))))
      }
      public static func milliseconds(_ ms: Int) -> Stride {
        return .init(.milliseconds(ms))
      }
      public static func microseconds(_ us: Int) -> Stride {
        return .init(.microseconds(us))
      }
      public static func nanoseconds(_ ns: Int) -> Stride {
        return .init(.nanoseconds(ns))
      }
    }
    /// The dispatch time represented by this type.
    public var dispatchTime: DispatchTime
    /// Creates a dispatch queue time type instance.
    ///
    /// - Parameter time: The dispatch time to represent.
    public init(_ time: DispatchTime) {
      dispatchTime = time
    }
    /// Returns the distance to another dispatch queue time.
    ///
    /// - Parameter other: Another dispatch queue time.
    /// - Returns: The time interval between this time and the provided time.
    public func distance(to other: SchedulerTimeType) -> Stride {
      return Stride.nanoseconds(self.dispatchTime.uptimeNanoseconds.intValue) - Stride.nanoseconds(other.dispatchTime.uptimeNanoseconds.intValue)
    }
    /// Returns a dispatch queue scheduler time calculated by advancing this instance’s time by the given interval.
    ///
    /// - Parameter n: A time interval to advance.
    /// - Returns: A dispatch queue time advanced by the given interval from this instance’s time.
    public func advanced(by n: Stride) -> SchedulerTimeType {
      return .init(self.dispatchTime + n.timeInterval)
    }
    public init(from decoder: Decoder) throws {
      let ns = try UInt64(from: decoder)
      self = .init(DispatchTime(uptimeNanoseconds: ns))
    }
    public func encode(to encoder: Encoder) throws {
      try dispatchTime.uptimeNanoseconds.encode(to: encoder)
    }
    public func hash(into hasher: inout Hasher) {
      hasher.combine(dispatchTime.uptimeNanoseconds)
    }
  }
  /// Options that affect the operation of the dispatch queue scheduler.
  public struct SchedulerOptions {
    /// The dispatch queue quality of service.
    public var qos: DispatchQoS
    /// The dispatch queue work item flags.
    public var flags: DispatchWorkItemFlags
    /// The dispatch group, if any, that should be used for performing actions.
    public var group: DispatchGroup?
    public init(qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = [], group: DispatchGroup? = nil) {
      self.qos = qos
      self.flags = flags
      self.group = group
    }
  }
  /// Returns the minimum tolerance allowed by the scheduler.
  public var minimumTolerance: SchedulerTimeType.Stride {
    return .seconds(0)
  }
  /// Returns this scheduler's definition of the current moment in time.
  public var now: SchedulerTimeType {
    return .init(.now())
  }
  /// Performs the action at the next possible opportunity.
  public func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
    let options = options ?? SchedulerOptions()
    base.async(group: options.group, qos: options.qos, flags: options.flags, execute: action)
  }
  /// Performs the action at some time after the specified date.
  public func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
    let options = options ?? SchedulerOptions()
    base.asyncAfter(deadline: date.dispatchTime, qos: options.qos, flags: options.flags, execute: action)
  }
  /// Performs the action at some time after the specified date, at the specified
  /// frequency, optionally taking into account tolerance if possible.
  public func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> _Cancellable {
    let options = options ?? SchedulerOptions()
    let timer = DispatchSource.makeTimerSource(flags: [], queue: base)
    timer.setEventHandler(qos: options.qos, flags: options.flags, handler: action)
    timer.schedule(deadline: date.dispatchTime, repeating: interval.timeInterval, leeway: tolerance.timeInterval)
    if #available(OSX 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
      timer.activate()
    } else {
      timer.resume()
    }
    return _AnyCancellable(timer.cancel)
  }
}
extension UInt64 {
  @usableFromInline
  var intValue: Int {
    return numericCast(Swift.min(UInt64(Int.max), self))
  }
}
extension DispatchTimeInterval {
  @usableFromInline
  var nanoseconds: Int {
    switch self {
    case .microseconds(let us): return us.signum() * (UInt64(abs(us)) * NSEC_PER_USEC).intValue
    case .milliseconds(let ms): return ms.signum() * (UInt64(abs(ms)) * NSEC_PER_MSEC).intValue
    case .nanoseconds(let ns):  return ns.signum() * UInt64(abs(ns)).intValue
    case .seconds(let s):       return s.signum()  * (UInt64(abs(s)) * NSEC_PER_SEC).intValue
    case .never:                return Int.max
    @unknown default:           return 0
    }
  }
}

