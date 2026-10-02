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

final class SpyNoteRepository: NoteRepository {
    var errorToThrow: Error?
    var notesToReturn: [Note] = []
    private(set) var savedNotes: [Note] = []
    private(set) var deletedNotes: [Note] = []
    private(set) var fetchedCategories: [NotitApp.Category] = []

    func save(_ note: Note) async throws {
        if let errorToThrow { throw errorToThrow }
        savedNotes.append(note)
    }

    func delete(_ note: Note) async throws {
        if let errorToThrow { throw errorToThrow }
        deletedNotes.append(note)
    }

    func fetchAll() async throws -> [Note] {
        if let errorToThrow { throw errorToThrow }
        return notesToReturn
    }

    func fetch(byCategory category: NotitApp.Category) async throws -> [Note] {
        if let errorToThrow { throw errorToThrow }
        fetchedCategories.append(category)
        return notesToReturn
    }
}

final class SpyCategoryRepository: CategoryRepository {
    var errorToThrow: Error?
    var categoriesToReturn: [NotitApp.Category] = []
    private(set) var savedCategories: [NotitApp.Category] = []
    private(set) var deletedCategories: [NotitApp.Category] = []

    func save(_ category: NotitApp.Category) async throws {
        if let errorToThrow { throw errorToThrow }
        savedCategories.append(category)
    }

    func delete(_ category: NotitApp.Category) async throws {
        if let errorToThrow { throw errorToThrow }
        deletedCategories.append(category)
    }

    func fetchAll() async throws -> [NotitApp.Category] {
        if let errorToThrow { throw errorToThrow }
        return categoriesToReturn
    }
}
