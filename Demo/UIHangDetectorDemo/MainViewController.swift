import UIKit
import Combine
import Then
import SnapKit
import UIHangDetector

class MainViewController: UIViewController {
    private let nonBlockingFreezeButton: UIButton = UIButton(type: .system).then {
        $0.setTitle("Run Non-Blocking", for: .normal)
        $0.setTitle("Stopped", for: .disabled)
        $0.sizeToFit()
    }
    
    private let blockingFreezeButton: UIButton = UIButton(type: .system).then {
        $0.setTitle("Run Blocking", for: .normal)
        $0.setTitle("Stopped", for: .disabled)
        $0.sizeToFit()
    }
    
    private let timerLabel: UILabel = UILabel().then {
        $0.textColor = .white
        $0.textAlignment = .center
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        self.nonBlockingFreezeButton.addTarget(self, action: #selector(self.nonBlockingButtonDidTap), for: .touchUpInside)
        self.blockingFreezeButton.addTarget(self, action: #selector(self.blockingButtonDidTap), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [
            self.nonBlockingFreezeButton,
            self.blockingFreezeButton,
            self.timerLabel,
        ])
        stack.axis = .vertical
        self.view.addSubview(stack)
        stack.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        self.timerDidFire(
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: self.timerDidFire)
        )
    }
    
    @objc
    private func nonBlockingButtonDidTap(_ sender: UIButton) {
        print("[\(Date())]\tButtonClicked")
        Task {
            sender.isEnabled = false
            try await Task.sleep(forDuration: 5(.seconds))
            sender.isEnabled = true
        }
    }
    
    @objc
    private func blockingButtonDidTap(_ sender: UIButton) {
        print("[\(Date())]\tButtonClicked")
        sender.isEnabled = false
        Thread.sleep(forDuration: 5(.seconds))
        sender.isEnabled = true
    }
    
    private func timerDidFire(_ timer: Timer) {
        let dateFormatter = DateFormatter().then {
            $0.dateFormat = "hh:mm:ss"
            $0.timeZone = TimeZone.current
        }
        self.timerLabel.text = dateFormatter.string(from: Date())
        
        switch (Int(Date().timeIntervalSince1970) % 3) {
        case 0: self.timerLabel.backgroundColor = UIColor.red
        case 1: self.timerLabel.backgroundColor = UIColor.green
        case 2: self.timerLabel.backgroundColor = UIColor.blue
        default: fatalError()
        }
    }
}
