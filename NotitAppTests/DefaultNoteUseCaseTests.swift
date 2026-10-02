import Foundation
import Testing
@testable import NotitApp

@MainActor
struct DefaultNoteUseCaseTests {

    private func makeNote(updatedAt: Date) -> Note {
        let createdAt = updatedAt
        return Note("Super", value: "Leche", category: Category("Compras", color: "RED"), createdAt: createdAt)
    }

    @Test func add_savesNoteThroughRepository() async throws {
        let repository = SpyNoteRepository()
        let sut = DefaultNoteUseCase(repository: repository)
        let note = makeNote(updatedAt: .now)

        try await sut.add(note)

        #expect(repository.savedNotes.map(\.id) == [note.id])
    }

    @Test func add_keepsUpdatedAtFromCreation() async throws {
        let createdAt = Date(timeIntervalSince1970: 1_000)
        let sut = DefaultNoteUseCase(repository: SpyNoteRepository())
        let note = makeNote(updatedAt: createdAt)

        try await sut.add(note)

        #expect(note.updatedAt == createdAt)
    }

    @Test func update_bumpsUpdatedAt_beforeSaving() async throws {
        // The notes list sorts by updatedAt, so an edit must move the note to
        // the top — this is the one business rule the use case owns.
        let repository = SpyNoteRepository()
        let sut = DefaultNoteUseCase(repository: repository)
        let stale = Date(timeIntervalSince1970: 1_000)
        let note = makeNote(updatedAt: stale)

        try await sut.update(note)

        #expect(note.updatedAt > stale)
        #expect(repository.savedNotes.map(\.id) == [note.id])
    }

    @Test func delete_deletesNoteThroughRepository() async throws {
        let repository = SpyNoteRepository()
        let sut = DefaultNoteUseCase(repository: repository)
        let note = makeNote(updatedAt: .now)

        try await sut.delete(note)

        #expect(repository.deletedNotes.map(\.id) == [note.id])
    }

    @Test func fetch_returnsRepositoryNotes() async throws {
        let repository = SpyNoteRepository()
        let note = makeNote(updatedAt: .now)
        repository.notesToReturn = [note]
        let sut = DefaultNoteUseCase(repository: repository)

        let notes = try await sut.fetch()

        #expect(notes.map(\.id) == [note.id])
    }

    @Test func fetchByCategory_forwardsCategoryToRepository() async throws {
        let repository = SpyNoteRepository()
        let category = Category("Trabajo", color: "BLUE")
        let sut = DefaultNoteUseCase(repository: repository)

        _ = try await sut.fetch(byCategory: category)

        #expect(repository.fetchedCategories.map(\.id) == [category.id])
    }

    @Test func repositoryErrors_propagate() async {
        let repository = SpyNoteRepository()
        repository.errorToThrow = StubError()
        let sut = DefaultNoteUseCase(repository: repository)
        let note = makeNote(updatedAt: .now)

        await #expect(throws: StubError.self) { try await sut.add(note) }
        await #expect(throws: StubError.self) { try await sut.update(note) }
        await #expect(throws: StubError.self) { try await sut.delete(note) }
        await #expect(throws: StubError.self) { _ = try await sut.fetch() }
    }
}
