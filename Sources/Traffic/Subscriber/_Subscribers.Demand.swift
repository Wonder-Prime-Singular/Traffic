extension _Subscribers {
  /// A requested number of items, sent to a publisher from a subscriber via the subscription.
  ///
  /// - unlimited: A request for an unlimited number of items.
  /// - max: A request for a maximum number of items.
  public struct Demand: ExpressibleByIntegerLiteral, Equatable, Comparable, Hashable, Codable, CustomStringConvertible {
    public typealias IntegerLiteralType = Int
    public init(integerLiteral value: IntegerLiteralType) {
      self.max = value
    }
    /// Requests as many values as the `Publisher` can produce.
    public static let unlimited: Demand = .init(maxValue: nil)
    /// A demand for no items.
    ///
    /// This is equivalent to `Demand.max(0)`.
    public static let none: Demand = .init(maxValue: 0)
    /// Limits the maximum number of values.
    /// The `Publisher` may send fewer than the requested number.
    /// Negative values will result in a `fatalError`.
    @inlinable
    public static func max(_ value: Int) -> Demand {
      precondition(value >= 0)
      return .init(maxValue: value)
    }
    @usableFromInline
    internal init(maxValue: Int?) {
      self.max = maxValue
    }
    @usableFromInline
    var max: Int?
    @inlinable
    public var isUnlimited: Bool {
      return max == nil
    }
    /// Returns `true` if `lhs` and `rhs` are equal. `.unlimited` is not equal to any integer.
    @inlinable
    public static func == (lhs: Demand, rhs: Int) -> Bool {
      return lhs.max == rhs
    }
    /// Returns `true` if `lhs` and `rhs` are not equal. `.unlimited` is not equal to any integer.
    @inlinable public static func != (lhs: Demand, rhs: Int) -> Bool {
      return lhs.max != rhs
    }
    /// Returns `true` if `lhs` and `rhs` are equal. `.unlimited` is not equal to any integer.
    @inlinable public static func == (lhs: Int, rhs: Demand) -> Bool {
      return lhs == rhs.max
    }
    /// Returns `true` if `lhs` and `rhs` are not equal. `.unlimited` is not equal to any integer.
    @inlinable public static func != (lhs: Int, rhs: Demand) -> Bool {
      return lhs != rhs.max
    }
    /// Returns a Boolean that indicates whether the first demand requests
    /// fewer elements than the second.
    ///
    /// If both sides are unlimited, the result is always false. If lhs is
    /// unlimited, then the result is always false. If rhs is unlimited then
    /// the result is always true. Otherwise, this operator compares
    /// the demands’ max values.
    /// 
    /// - Parameters:
    ///   - lhs: A demand to compare.
    ///   - rhs: Another demand to compare.
    @inlinable
    public static func < (lhs: Demand, rhs: Demand) -> Bool {
      switch (lhs.isUnlimited, rhs.isUnlimited) {
      case (true, _):
        return false
      case (_, true):
        return true
      default:
        return lhs.max! < rhs.max!
      }
    }
    @inlinable
    public static func > (lhs: Demand, rhs: Int) -> Bool {
      return lhs > Demand.max(rhs)
    }
    @inlinable
    public static func >= (lhs: Demand, rhs: Int) -> Bool {
      return lhs >= Demand.max(rhs)
    }
    @inlinable
    public static func > (lhs: Int, rhs: Demand) -> Bool {
      return Demand.max(lhs) > rhs
    }
    @inlinable
    public static func >= (lhs: Int, rhs: Demand) -> Bool {
      return Demand.max(lhs) >= rhs
    }
    @inlinable
    public static func < (lhs: Demand, rhs: Int) -> Bool {
      return lhs < Demand.max(rhs)
    }
    @inlinable
    public static func <= (lhs: Demand, rhs: Int) -> Bool {
      return lhs <= Demand.max(rhs)
    }
    @inlinable
    public static func < (lhs: Int, rhs: Demand) -> Bool {
      return Demand.max(lhs) < rhs
    }
    @inlinable
    public static func <= (lhs: Int, rhs: Demand) -> Bool {
      return Demand.max(lhs) <= rhs
    }
    /// When adding any value to .unlimited, the result is .unlimited.
    @inlinable
    public static func + (lhs: Demand, rhs: Demand) -> Demand {
      if lhs.isUnlimited || rhs.isUnlimited {
        return .unlimited
      }
      let (partialValue, overflow) = lhs.max!.addingReportingOverflow(rhs.max!)
      return overflow ? .unlimited : Demand(maxValue: partialValue)
    }
    @inlinable
    public static func + (lhs: Demand, rhs: Int) -> Demand {
      return lhs + Demand.max(rhs)
    }
    @inlinable
    public static func += (lhs: inout Demand, rhs: Demand) -> Void {
      lhs = lhs + rhs
    }
    @inlinable
    public static func += (lhs: inout Demand, rhs: Int) -> Void {
      lhs = lhs + rhs
    }
    @inlinable
    static func * (lhs: Demand, rhs: Int) -> Demand {
      if lhs.isUnlimited {
        return .unlimited
      }
      let (partialValue, overflow) = lhs.max!.multipliedReportingOverflow(by: rhs)
      return overflow ? .unlimited : Demand(maxValue: partialValue)
    }
    @inlinable
    public static func *= (lhs: inout Demand, rhs: Int) -> Void {
      lhs = lhs * rhs
    }
    /// When subtracting any value (including .unlimited) from .unlimited, the result is still .unlimited. Subtracting unlimited from any value (except unlimited) results in .max(0). A negative demand is not possible; any operation that would result in a negative value is clamped to .max(0).
    @inlinable
    public static func - (lhs: Demand, rhs: Demand) -> Demand {
      if lhs.isUnlimited {
        return .unlimited
      }
      if rhs.isUnlimited {
        return .none
      }
      let (partialValue, overflow) = lhs.max!.subtractingReportingOverflow(rhs.max!)
      return overflow ? .none : Demand(maxValue: Swift.max(0, partialValue))
    }
    @inlinable
    public static func - (lhs: Demand, rhs: Int) -> Demand {
      return lhs - Demand.max(rhs)
    }
    @inlinable
    public static func -= (lhs: inout Demand, rhs: Demand) -> Void {
      lhs = lhs - rhs
    }
    @inlinable
    public static func -= (lhs: inout Demand, rhs: Int) -> Void {
      lhs = lhs - rhs
    }
    public var description: String {
      switch self {
      case .unlimited:
        return "unlimited"
      default:
        return "max: (\(max!))"
      }
    }
  }
}
