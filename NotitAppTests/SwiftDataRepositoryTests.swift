import Testing
import SwiftData
@testable import NotitApp

@MainActor
struct SwiftDataRepositoryTests {

    // ModelContext does not keep its owning ModelContainer alive. The
    // container must be retained by the caller for as long as the context
    // is used, or SwiftData crashes on first access to the dangling context.
    private func makeContainer() throws -> ModelContainer {
        try ModelContainer(
            for: Note.self, Category.self,
            configurations: .init(isStoredInMemoryOnly: true)
        )
    }

    @Test func noteRepository_save_and_fetchAll_returnsSavedNote() async throws {
        let container = try makeContainer()
        let sut = SwiftDataNoteRepository(context: container.mainContext)
        let category = Category("Compras", color: "RED")
        let note = Note("Super", value: "Leche", category: category, createdAt: .now)

        try await sut.save(note)
        let notes = try await sut.fetchAll()

        #expect(notes.count == 1)
        #expect(notes.first?.title == "Super")
    }

    @Test func noteRepository_delete_removesNote() async throws {
        let container = try makeContainer()
        let sut = SwiftDataNoteRepository(context: container.mainContext)
        let category = Category("Compras", color: "RED")
        let note = Note("Super", value: "Leche", category: category, createdAt: .now)
        try await sut.save(note)

        try await sut.delete(note)
        let notes = try await sut.fetchAll()

        #expect(notes.isEmpty)
    }

    @Test func noteRepository_fetchByCategory_returnsOnlyMatchingNotes() async throws {
        let container = try makeContainer()
        let sut = SwiftDataNoteRepository(context: container.mainContext)
        let compras = Category("Compras", color: "RED")
        let viajes = Category("Viajes", color: "BLUE")
        try await sut.save(Note("Super", value: "Leche", category: compras, createdAt: .now))
        try await sut.save(Note("Vuelo", value: "Reservar", category: viajes, createdAt: .now))

        let notes = try await sut.fetch(byCategory: compras)

        #expect(notes.count == 1)
        #expect(notes.first?.title == "Super")
    }

    @Test func categoryRepository_save_and_fetchAll_returnsSortedByName() async throws {
        let container = try makeContainer()
        let sut = SwiftDataCategoryRepository(context: container.mainContext)
        try await sut.save(Category("Viajes", color: "BLUE"))
        try await sut.save(Category("Compras", color: "RED"))

        let categories = try await sut.fetchAll()

        #expect(categories.map(\.name) == ["Compras", "Viajes"])
    }

    @Test func categoryRepository_delete_removesCategory() async throws {
        let container = try makeContainer()
        let sut = SwiftDataCategoryRepository(context: container.mainContext)
        let category = Category("Compras", color: "RED")
        try await sut.save(category)

        try await sut.delete(category)
        let categories = try await sut.fetchAll()

        #expect(categories.isEmpty)
    }
}
