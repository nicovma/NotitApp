import Testing
@testable import NotitApp

@MainActor
struct EditNoteViewModelTests {

    private func makeNote(category: Category) -> Note {
        Note("Original", value: "Contenido original", category: category, createdAt: .now)
    }

    @Test func init_prefillsFieldsFromNote() async {
        let category = Category("Trabajo", color: "BLUE")
        let note = makeNote(category: category)
        let sut = EditNoteViewModel(note: note, noteUseCase: MockNoteUseCase(), categoryUseCase: MockCategoryUseCase())

        #expect(sut.title == "Original")
        #expect(sut.value == "Contenido original")
        #expect(sut.selectedCategory == category)
    }

    @Test func saveChanges_withEmptyTitle_setsErrorAndDoesNotSave() async {
        let noteUseCase = MockNoteUseCase()
        let note = makeNote(category: Category("Trabajo", color: "BLUE"))
        let sut = EditNoteViewModel(note: note, noteUseCase: noteUseCase, categoryUseCase: MockCategoryUseCase())
        sut.title = "   "

        await sut.saveChanges()

        #expect(sut.errorMessage != nil)
        #expect(!noteUseCase.updateCalled)
        #expect(!sut.didSave)
    }

    @Test func saveChanges_withoutSelectedCategory_setsError() async {
        let noteUseCase = MockNoteUseCase()
        let note = makeNote(category: Category("Trabajo", color: "BLUE"))
        let sut = EditNoteViewModel(note: note, noteUseCase: noteUseCase, categoryUseCase: MockCategoryUseCase())
        sut.selectedCategory = nil

        await sut.saveChanges()

        #expect(sut.errorMessage != nil)
        #expect(!noteUseCase.updateCalled)
    }

    @Test func saveChanges_valid_updatesNoteAndMarksDidSave() async {
        let noteUseCase = MockNoteUseCase()
        let originalCategory = Category("Trabajo", color: "BLUE")
        let newCategory = Category("Personal", color: "GREEN")
        let note = makeNote(category: originalCategory)
        let sut = EditNoteViewModel(note: note, noteUseCase: noteUseCase, categoryUseCase: MockCategoryUseCase())
        sut.title = "Editado"
        sut.value = "Contenido editado"
        sut.selectedCategory = newCategory

        await sut.saveChanges()

        #expect(noteUseCase.updateCalled)
        #expect(sut.didSave)
        #expect(sut.errorMessage == nil)
        #expect(note.title == "Editado")
        #expect(note.value == "Contenido editado")
        #expect(note.category == newCategory)
    }
}
