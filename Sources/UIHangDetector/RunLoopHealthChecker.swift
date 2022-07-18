import Foundation
import Combine

internal final class RunLoopHealthChecker {
    private let healthSubject = PassthroughSubject<Health, Never>()
    
    private var timerThread: Thread?
    private var subscription: AnyCancellable?
    
    private let target: RunLoop
    private let warningCriteria: TimeInterval
    private let criticalCriteria: TimeInterval
    private let healthSignalInterval: TimeInterval
    private let healthSignalCheckInterval: TimeInterval
    
    var healthStream: AnyPublisher<Health, Never> {
        get {
            return self.healthSubject.eraseToAnyPublisher()
        }
    }
    
    init(
        target: RunLoop,
        warningCriteria: Duration,
        criticalCriteria: Duration,
        healthSignalInterval: Duration,
        healthSignalCheckInterval: Duration
    ) {
        self.target = target
        self.warningCriteria = warningCriteria.converted(to: .seconds).value
        self.criticalCriteria = criticalCriteria.converted(to: .seconds).value
        self.healthSignalInterval = healthSignalInterval.converted(to: .seconds).value
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
        let healthSignalCheckTimer = Timer
            .publish(every: self.healthSignalCheckInterval, on: RunLoop.current, in: .common)
            .autoconnect()
        let healthSignalStream = Timer
            .publish(every: self.healthSignalInterval, on: self.target, in: .common)
            .autoconnect()
            .prepend(AnyPublisher(Date()).receive(on: self.target))
            .receive(on: RunLoop.current)

        self.subscription = healthSignalCheckTimer.combineLatest(healthSignalStream)
            .compactMap { (now: Date, lastSignal: Date) -> TimeInterval in
                return now.timeIntervalSince(lastSignal)
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
}
