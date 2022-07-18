import Foundation
import Combine

internal extension AnyPublisher where Failure == Never {
    init(_ output: Output) {
        self = Optional.Publisher(output)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
}
