import XCTest
import Combine
@testable import UIHangDetector

final class UIHangDetectorTests: XCTestCase {
    func test_sut_should_detect_warning_state() async throws {
        // Arrange
        let sut = UIHangDetector(
            warningCriteria: 500(.milliseconds),
            criticalCriteria: 1(.seconds),
            healthSignalInterval: 500(.milliseconds),
            healthSignalCheckInterval: 100(.milliseconds)
        )
        
        var history: [Health] = []
        var cancellableStorage = Set<AnyCancellable>()
        sut.healthStream
            .sink { history.append($0) }
            .store(in: &cancellableStorage)
        
        // Act
        sut.start()
        DispatchQueue.main.async {
            Thread.sleep(forDuration: 700(.milliseconds))
        }
        
        // Arrange
        try await Task.sleep(forDuration: 600(.milliseconds))
        XCTAssertTrue(history.dropFirst() == [.warning])
    }

    func test_sut_should_detect_critical_state() async throws {
        // Arrange
        let sut = UIHangDetector(
            warningCriteria: 500(.milliseconds),
            criticalCriteria: 1(.seconds),
            healthSignalInterval: 500(.milliseconds),
            healthSignalCheckInterval: 100(.milliseconds)
        )
        
        var history: [Health] = []
        var cancellableStorage = Set<AnyCancellable>()
        sut.healthStream
            .sink { history.append($0) }
            .store(in: &cancellableStorage)
        
        // Act
        sut.start()
        DispatchQueue.main.async {
            Thread.sleep(forDuration: 1.3(.seconds))
        }
        
        // Arrange
        try await Task.sleep(forDuration: 1.1(.seconds))
        XCTAssertTrue(history.dropFirst(2) == [.critical])
    }
    
    func test_sut_should_detect_state_recovered_from_warning() async throws {
        // Arrange
        let sut = UIHangDetector(
            warningCriteria: 500(.milliseconds),
            criticalCriteria: 1(.seconds),
            healthSignalInterval: 500(.milliseconds),
            healthSignalCheckInterval: 100(.milliseconds)
        )
        
        var history: [Health] = []
        var cancellableStorage = Set<AnyCancellable>()
        sut.healthStream
            .sink { history.append($0) }
            .store(in: &cancellableStorage)
        
        // Act
        sut.start()
        DispatchQueue.main.async {
            Thread.sleep(forDuration: 600(.milliseconds))
        }
        
        // Arrange
        try await Task.sleep(forDuration: 800(.milliseconds))
        XCTAssertTrue(history == [.good, .warning, .good])
    }
    
    func test_sut_should_detect_state_recovered_from_critical() async throws {
        // Arrange
        let sut = UIHangDetector(
            warningCriteria: 500(.milliseconds),
            criticalCriteria: 1(.seconds),
            healthSignalInterval: 500(.milliseconds),
            healthSignalCheckInterval: 100(.milliseconds)
        )
        
        var history: [Health] = []
        var cancellableStorage = Set<AnyCancellable>()
        sut.healthStream
            .sink { history.append($0) }
            .store(in: &cancellableStorage)
        
        // Act
        sut.start()
        DispatchQueue.main.async {
            Thread.sleep(forDuration: 1.1(.seconds))
        }
        
        // Arrange
        try await Task.sleep(forDuration: 1.3(.seconds))
        XCTAssertTrue(history == [.good, .warning, .critical, .good])
    }
    
    func test_sut_should_handle_first_health_signal_correctly() async throws {
        // Arrange
        let sut = UIHangDetector(
            warningCriteria: 500(.milliseconds),
            criticalCriteria: 1(.seconds),
            healthSignalInterval: 500(.milliseconds),
            healthSignalCheckInterval: 100(.milliseconds)
        )
        
        var history: [Health] = []
        var cancellableStorage = Set<AnyCancellable>()
        sut.healthStream
            .sink { history.append($0) }
            .store(in: &cancellableStorage)
        
        // Act
        DispatchQueue.main.async {
            DispatchQueue.global().sync {
                sut.start()
            }
            
            DispatchQueue.main.async {
                Thread.sleep(forDuration: 1.1(.seconds))
            }
        }
        
        // Arrange
        try await Task.sleep(forDuration: 1.2(.seconds))
        XCTAssertTrue(history == [.good, .warning, .critical, .good])
    }
}
