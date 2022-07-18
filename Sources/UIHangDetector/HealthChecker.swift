import Foundation
import Combine

internal final class HealthChecker {
    private let healthSubject = PassthroughSubject<Health, Never>()
    private let healthSignalSubject = CurrentValueSubject<Date, Never>(Date.distantPast)
    
    private var timerThread: Thread?
    private var subscription: AnyCancellable?
    
    private let warningCriteria: TimeInterval
    private let criticalCriteria: TimeInterval
    private let healthSignalCheckInterval: TimeInterval
    
    var healthStream: AnyPublisher<Health, Never> {
        get {
            return self.healthSubject.eraseToAnyPublisher()
        }
    }
    
    init(
        warningCriteria: Duration,
        criticalCriteria: Duration,
        healthSignalCheckInterval: Duration
    ) {
        self.warningCriteria = warningCriteria.converted(to: .seconds).value
        self.criticalCriteria = criticalCriteria.converted(to: .seconds).value
        self.healthSignalCheckInterval = healthSignalCheckInterval.converted(to: .seconds).value
    }

    func start() {
        guard self.timerThread == nil else { return }
        guard self.subscription == nil else { return }

        let timerThread = Thread(block: self.startImpl)
        timerThread.name = "HealthChecker"
        self.timerThread = timerThread
        self.timerThread?.start()
    }
    
    private func startImpl() {
        self.subscription = Timer.publish(every: self.healthSignalCheckInterval, on: RunLoop.current, in: .common)
            .autoconnect()
            .combineLatest(self.healthSignalSubject.receive(on: RunLoop.current))
            .compactMap { (now: Date, lastSignal: Date) -> TimeInterval in
                now.timeIntervalSince(lastSignal)
            }
            .map { (timeDiff: TimeInterval) -> Health in
                switch (timeDiff) {
                case ..<self.warningCriteria:
                    return .good
                case self.warningCriteria ..< self.criticalCriteria:
                    return .warning
                case self.criticalCriteria...:
                    return .critical
                default: fatalError()
                }
            }
            .removeDuplicates()
            .subscribe(self.healthSubject)

        RunLoop.current.run()
    }
    
    func stop() {
        self.subscription?.cancel()
        self.subscription = nil
        
        self.timerThread?.cancel()
        self.timerThread = nil
    }
    
    func acceptHealthSignal() {
        self.healthSignalSubject.send(Date())
    }
}
