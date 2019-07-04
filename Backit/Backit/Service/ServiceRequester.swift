import BrightFutures
import Foundation

protocol ServiceRequester {
    func initialized<T: ServiceEndpoint>(_ endpoint: T) -> Future<IgnorableValue, NoError>
    func request(_ urlRequest: URLRequest, callback: @escaping (ServiceResult) -> Void)
}
