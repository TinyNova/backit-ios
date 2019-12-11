import BrightFutures
import Foundation

class CategoryService: CategoryProvider {

    private let service: Service

    init(service: Service) {
        self.service = service
    }

    func categories() -> Future<[Category], CategoryProviderError> {
        return Future(value: [Category(id: 1, name: "Board Games")])
    }
}
