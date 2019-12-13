import BrightFutures
import Foundation

class CategoryService: CategoryProvider {

    private let service: Service

    init(service: Service) {
        self.service = service
    }

    func categories() -> Future<[Category], CategoryProviderError> {
        let endpoint = CategoriesEndpoint()
        return service.request(endpoint)
            .map { (result) -> [Category] in
                return result.categories.compactMap { (cat) -> Category? in
                    guard let id = cat.categoryId, let name = cat.name else {
                        log.w("category has issues: \(cat)")
                        return nil
                    }
                    return Category(id: id, name: name)
                }
            }
            .mapError { (error) -> CategoryProviderError in
                return .generic(error)
            }
    }
}
