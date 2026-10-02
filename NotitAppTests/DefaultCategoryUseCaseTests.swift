import Testing
@testable import NotitApp

@MainActor
struct DefaultCategoryUseCaseTests {

    @Test func add_savesCategoryThroughRepository() async throws {
        let repository = SpyCategoryRepository()
        let sut = DefaultCategoryUseCase(repository: repository)
        let category = Category("Trabajo", color: "BLUE")

        try await sut.add(category)

        #expect(repository.savedCategories.map(\.id) == [category.id])
    }

    @Test func update_savesCategoryThroughRepository() async throws {
        let repository = SpyCategoryRepository()
        let sut = DefaultCategoryUseCase(repository: repository)
        let category = Category("Trabajo", color: "BLUE")

        try await sut.update(category)

        #expect(repository.savedCategories.map(\.id) == [category.id])
    }

    @Test func delete_deletesCategoryThroughRepository() async throws {
        let repository = SpyCategoryRepository()
        let sut = DefaultCategoryUseCase(repository: repository)
        let category = Category("Trabajo", color: "BLUE")

        try await sut.delete(category)

        #expect(repository.deletedCategories.map(\.id) == [category.id])
    }

    @Test func fetch_returnsRepositoryCategories() async throws {
        let repository = SpyCategoryRepository()
        let category = Category("Trabajo", color: "BLUE")
        repository.categoriesToReturn = [category]
        let sut = DefaultCategoryUseCase(repository: repository)

        let categories = try await sut.fetch()

        #expect(categories.map(\.id) == [category.id])
    }

    @Test func repositoryErrors_propagate() async {
        let repository = SpyCategoryRepository()
        repository.errorToThrow = StubError()
        let sut = DefaultCategoryUseCase(repository: repository)
        let category = Category("Trabajo", color: "BLUE")

        await #expect(throws: StubError.self) { try await sut.add(category) }
        await #expect(throws: StubError.self) { try await sut.update(category) }
        await #expect(throws: StubError.self) { try await sut.delete(category) }
        await #expect(throws: StubError.self) { _ = try await sut.fetch() }
    }
}
