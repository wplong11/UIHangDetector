import Foundation
import Combine

public final class UIHangDetector {
    private let healthChecker: RunLoopHealthChecker
    private var timer: Timer?
    
    public var healthStream: AnyPublisher<Health, Never> {
        get {
            return self.healthChecker.healthStream
        }
    }
    
    public init(
        warningCriteria: Duration,
        criticalCriteria: Duration,
        healthSignalInterval: Duration = 0.5(.seconds),
        healthSignalCheckInterval: Duration = 0.1(.seconds)
    ) {
        self.healthChecker = RunLoopHealthChecker(
            target: RunLoop.main,
            warningCriteria: warningCriteria,
            criticalCriteria: criticalCriteria,
            healthSignalInterval: healthSignalInterval,
            healthSignalCheckInterval: healthSignalCheckInterval
        )
    }
    
    public func start() {
        self.healthChecker.start()
    }
    
    public func stop() {
        self.healthChecker.stop()
    }
}
