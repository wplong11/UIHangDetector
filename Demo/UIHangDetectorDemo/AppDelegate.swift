import UIKit
import Combine
import UIHangDetector

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    private let hangDetector = UIHangDetector(
        warningCriteria: 600(.milliseconds),
        criticalCriteria: 1000(.milliseconds),
        healthSignalInterval: 500(.milliseconds),
        healthSignalCheckInterval: 100(.milliseconds)
    )
    
    private var cancellableBag: Set<AnyCancellable> = []
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        self.window = UIWindow().then {
            $0.backgroundColor = .black
            $0.rootViewController = MainViewController()
        }
        self.window?.makeKeyAndVisible()
        
        self.hangDetector.healthStream
            .sink { print("[\(Date())]\t\($0)") }
            .store(in: &self.cancellableBag)
        self.hangDetector.start()

//        _ = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { _ in
//            self.hangDetector.stop()
//        }
//
//        _ = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { _ in
//            self.hangDetector.start()
//        }

        return true
    }
}
