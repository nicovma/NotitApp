@testable import NotitApp

struct StubError: Error {}

final class ThrowingNoteUseCase: NoteUseCase {
    func add(_ note: Note) async throws { throw StubError() }
    func update(_ note: Note) async throws { throw StubError() }
    func delete(_ note: Note) async throws { throw StubError() }
    func fetch() async throws -> [Note] { throw StubError() }
    func fetch(byCategory category: NotitApp.Category) async throws -> [Note] { throw StubError() }
}

final class ThrowingCategoryUseCase: CategoryUseCase {
    func add(_ category: NotitApp.Category) async throws { throw StubError() }
    func update(_ category: NotitApp.Category) async throws { throw StubError() }
    func delete(_ category: NotitApp.Category) async throws { throw StubError() }
    func fetch() async throws -> [NotitApp.Category] { throw StubError() }
}

final class ThrowingNoteSuggestionUseCase: NoteSuggestionUseCase {
    var isAvailable: Bool { true }
    var unavailableReason: String? { nil }
    func suggest(for text: String, existingCategories: [NotitApp.Category], previousSuggestion: NoteSuggestion?) async throws -> NoteSuggestion {
        throw StubError()
    }
}
