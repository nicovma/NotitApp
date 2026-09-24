import Testing
@testable import NotitApp

@MainActor
struct CategoryListViewModelTests {

    @Test func fetchCategories_success_updatesStateToLoaded() async {
        let sut = CategoryListViewModel(useCase: MockCategoryUseCase())

        await sut.fetchCategories()

        guard case .loaded(let categories) = sut.state else {
            Issue.record("Expected .loaded, got \(sut.state)")
            return
        }
        #expect(!categories.isEmpty)
    }

    @Test func fetchCategories_failure_updatesStateToError() async {
        let sut = CategoryListViewModel(useCase: ThrowingCategoryUseCase())

        await sut.fetchCategories()

        guard case .error = sut.state else {
            Issue.record("Expected .error, got \(sut.state)")
            return
        }
    }

    @Test func deleteCategory_removesCategoryAndRefreshesList() async {
        let useCase = MockCategoryUseCase()
        let sut = CategoryListViewModel(useCase: useCase)
        await sut.fetchCategories()
        let toDelete = useCase.categories[0]

        await sut.deleteCategory(toDelete)

        #expect(useCase.deleteCalled)
        guard case .loaded(let categories) = sut.state else {
            Issue.record("Expected .loaded, got \(sut.state)")
            return
        }
        #expect(!categories.contains { $0.id == toDelete.id })
    }
}
