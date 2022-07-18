# UIHangDetector

UIHangDetector is a tool to detect UI Hang (a.k.a UI Freezing) in real time. The reason for not adopting [MetricKit](https://developer.apple.com/documentation/metrickit) is that it does not provide real-time information on whether a UI Hang has occurred. We invented UIHangDetector to implement the scenario of clearing local cache which causes UI Hang.

## How to use

You can reference [Demo App](https://github.com/wplong11/UIHangDetector/tree/main/Demo), [Test Code](https://github.com/wplong11/UIHangDetector/blob/main/Tests/UIHangDetectorTests/UIHangDetectorTests.swift) or below

```swift
import UIHangDetector
import Combine

// ...

let sut = UIHangDetector(
    warningCriteria: 500(.milliseconds),
    criticalCriteria: 1(.seconds),
    healthSignalInterval: 500(.milliseconds),
    healthSignalCheckInterval: 100(.milliseconds)
)

var cancellableStorage = Set<AnyCancellable>()
sut.healthStream
    .sink {
      switch $0 {
      case .good:
        print("good!")

      case .warning:
        print("warning!")
        
      case .critical:
        print("ciritical!")
      }
    }
    .store(in: &cancellableStorage)
```
