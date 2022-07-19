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
    healthSignalInterval: 100(.milliseconds),
    healthSignalCheckInterval: 50(.milliseconds)
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

## How does it work

A timer running on the UI thread records the signal as a timestamp that the UI thread is alive, and the timer running on the background thread checks the time of the last signal received from the UI thread. If the time of receiving the last signal exceeds the threshold, the UI Thread health state becomes Warning or Critical. UI Thread health state naming(Good, Warning, Critical) is inspired by [Azure status] (https://status.azure.com/en-us/status)

## Under the hood

UI hang occurs when RunLoop of UI Thread (Main Thread) executes heavy tasks, so the rendering cycle executed in RunLoop becomes longer. The key idea is that the timers connected to RunLoop are not also fired at this time.

[![runloop](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/Art/runloop.jpg)](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/RunLoopManagement/RunLoopManagement.html)

## TODO

- [ ] Support for background/foreground app switching
  - The timer stops when it goes to the background. Therefore, a false alert may occur if the last signal time is not adjusted when switching to the foreground.
