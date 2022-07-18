import Foundation
import Combine

public final class UIHangDetector {
    private let healthSignalInterval: TimeInterval
    private let healthChecker: HealthChecker
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
        self.healthSignalInterval = healthSignalInterval.converted(to: .seconds).value
        self.healthChecker = HealthChecker(
            warningCriteria: warningCriteria,
            criticalCriteria: criticalCriteria,
            healthSignalCheckInterval: healthSignalCheckInterval
        )
    }
    
    public func start() {
        self.healthChecker.start()
        
        DispatchQueue.main.async {
            self.healthChecker.acceptHealthSignal()
            self.timer = Timer.scheduledTimer(withTimeInterval: self.healthSignalInterval, repeats: true) { _ in
                self.healthChecker.acceptHealthSignal()
            }
        }
    }
    
    public func stop() {
        self.healthChecker.stop()
        
        self.timer?.invalidate()
        self.timer = nil
    }
}
