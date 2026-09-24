import Testing
@testable import NotitApp

@MainActor
struct NoteListViewModelTests {

    @Test func fetchNotes_success_updatesStateToLoaded() async {
        let category = Category("Compras", color: "RED")
        let note = Note("Super", value: "Leche", category: category, createdAt: .now)
        let sut = NoteListViewModel(useCase: MockNoteUseCase(notes: [note]))

        await sut.fetchNotes()

        guard case .loaded(let notes) = sut.state else {
            Issue.record("Expected .loaded, got \(sut.state)")
            return
        }
        #expect(notes.count == 1)
        #expect(notes.first?.title == "Super")
    }

    @Test func fetchNotes_failure_updatesStateToError() async {
        let sut = NoteListViewModel(useCase: ThrowingNoteUseCase())

        await sut.fetchNotes()

        guard case .error = sut.state else {
            Issue.record("Expected .error, got \(sut.state)")
            return
        }
    }

    @Test func delete_removesNoteAndRefreshesList() async {
        let category = Category("Compras", color: "RED")
        let note = Note("Super", value: "Leche", category: category, createdAt: .now)
        let useCase = MockNoteUseCase(notes: [note])
        let sut = NoteListViewModel(useCase: useCase)
        await sut.fetchNotes()

        await sut.delete(note)

        #expect(useCase.deleteCalled)
        guard case .loaded(let notes) = sut.state else {
            Issue.record("Expected .loaded, got \(sut.state)")
            return
        }
        #expect(notes.isEmpty)
    }
}
