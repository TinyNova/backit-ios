import BrightFutures
import Foundation

enum CategoryProviderError: Error {
    case generic(Error)
}

protocol CategoryProvider {
    func categories() -> Future<[Category], CategoryProviderError>
}
