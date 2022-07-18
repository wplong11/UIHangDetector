import Foundation

public typealias Duration = Measurement<UnitDuration>

public extension Double {
  func callAsFunction <U: Dimension>(_ units: U) -> Measurement<U> {
       Measurement(value: self, unit: units)
  }
}

public extension Int {
  func callAsFunction <U: Dimension>(_ units: U) -> Measurement<U> {
       Measurement(value: Double(self), unit: units)
  }
}

public extension Thread {
    class func sleep(forDuration duration: Duration) {
        Self.sleep(forTimeInterval: duration.converted(to: .seconds).value)
    }
}

public extension Task where Success == Never, Failure == Never {
    static func sleep(forDuration duration: Duration) async throws {
        try await Self.sleep(nanoseconds: UInt64(duration.converted(to: .nanoseconds).value))
    }
}
