import Testing
@testable import NotitApp

@MainActor
struct AddNoteViewModelTests {

    @Test func loadCategories_populatesListAndDefaultsSelection() async {
        let categoryUseCase = MockCategoryUseCase()
        let sut = AddNoteViewModel(noteUseCase: MockNoteUseCase(), categoryUseCase: categoryUseCase, noteSuggestionUseCase: MockNoteSuggestionUseCase())

        await sut.loadCategories()

        #expect(sut.categories.count == categoryUseCase.categories.count)
        #expect(sut.selectedCategory != nil)
    }

    @Test func createNote_withEmptyTitle_setsErrorAndDoesNotSave() async {
        let noteUseCase = MockNoteUseCase()
        let sut = AddNoteViewModel(noteUseCase: noteUseCase, categoryUseCase: MockCategoryUseCase(), noteSuggestionUseCase: MockNoteSuggestionUseCase())
        sut.title = "   "

        await sut.createNote()

        #expect(sut.errorMessage != nil)
        #expect(!noteUseCase.addCalled)
        #expect(!sut.didSave)
    }

    @Test func createNote_withoutSelectedCategory_setsError() async {
        let noteUseCase = MockNoteUseCase()
        let sut = AddNoteViewModel(noteUseCase: noteUseCase, categoryUseCase: MockCategoryUseCase(), noteSuggestionUseCase: MockNoteSuggestionUseCase())
        sut.title = "Nueva nota"

        await sut.createNote()

        #expect(sut.errorMessage != nil)
        #expect(!noteUseCase.addCalled)
    }

    @Test func createNote_valid_savesAndMarksDidSave() async {
        let noteUseCase = MockNoteUseCase()
        let sut = AddNoteViewModel(noteUseCase: noteUseCase, categoryUseCase: MockCategoryUseCase(), noteSuggestionUseCase: MockNoteSuggestionUseCase())
        await sut.loadCategories()
        sut.title = "Nueva nota"
        sut.value = "Detalle"

        await sut.createNote()

        #expect(noteUseCase.addCalled)
        #expect(sut.didSave)
        #expect(sut.errorMessage == nil)
    }

    @Test func requestSuggestion_withExistingCategoryMatch_resolvesSuggestedCategory() async {
        let categoryUseCase = MockCategoryUseCase()
        let suggestion = NoteSuggestion(title: "Súper", categoryName: categoryUseCase.categories[0].name, isNewCategory: false)
        let suggestionUseCase = MockNoteSuggestionUseCase(result: .success(suggestion))
        let sut = AddNoteViewModel(noteUseCase: MockNoteUseCase(), categoryUseCase: categoryUseCase, noteSuggestionUseCase: suggestionUseCase)
        await sut.loadCategories()
        sut.value = "Comprar leche, pan y huevos en el súper"

        await sut.requestSuggestion()

        #expect(suggestionUseCase.suggestCalled)
        #expect(sut.suggestion?.title == "Súper")
        #expect(sut.suggestedCategory?.name == categoryUseCase.categories[0].name)
    }

    @Test func requestSuggestion_withNewCategory_leavesSuggestedCategoryNil() async {
        let suggestion = NoteSuggestion(title: "Idea", categoryName: "Proyectos", isNewCategory: true)
        let suggestionUseCase = MockNoteSuggestionUseCase(result: .success(suggestion))
        let sut = AddNoteViewModel(noteUseCase: MockNoteUseCase(), categoryUseCase: MockCategoryUseCase(), noteSuggestionUseCase: suggestionUseCase)
        await sut.loadCategories()
        sut.value = "Armar el pitch para el proyecto nuevo del laburo"

        await sut.requestSuggestion()

        #expect(sut.suggestion?.categoryName == "Proyectos")
        #expect(sut.suggestedCategory == nil)
    }

    @Test func requestSuggestion_whenUseCaseThrows_failsSilentlyWithoutErrorMessage() async {
        let sut = AddNoteViewModel(noteUseCase: MockNoteUseCase(), categoryUseCase: MockCategoryUseCase(), noteSuggestionUseCase: ThrowingNoteSuggestionUseCase())
        sut.value = "Un texto lo suficientemente largo como para disparar la sugerencia"

        await sut.requestSuggestion()

        #expect(sut.suggestion == nil)
        #expect(sut.errorMessage == nil)
    }

    @Test func applySuggestedTitle_setsTitleFromSuggestion() async {
        let suggestion = NoteSuggestion(title: "Lista del súper", categoryName: "Compras", isNewCategory: false)
        let sut = AddNoteViewModel(noteUseCase: MockNoteUseCase(), categoryUseCase: MockCategoryUseCase(), noteSuggestionUseCase: MockNoteSuggestionUseCase(result: .success(suggestion)))
        sut.value = "Comprar leche, pan y huevos en el súper"
        await sut.requestSuggestion()

        sut.applySuggestedTitle()

        #expect(sut.title == "Lista del súper")
    }

    @Test func applySuggestedCategory_whenNew_createsAndSelectsCategory() async {
        let categoryUseCase = MockCategoryUseCase()
        let suggestion = NoteSuggestion(title: "Idea", categoryName: "Proyectos", isNewCategory: true)
        let sut = AddNoteViewModel(noteUseCase: MockNoteUseCase(), categoryUseCase: categoryUseCase, noteSuggestionUseCase: MockNoteSuggestionUseCase(result: .success(suggestion)))
        await sut.loadCategories()
        sut.value = "Armar el pitch para el proyecto nuevo del laburo"
        await sut.requestSuggestion()

        await sut.applySuggestedCategory()

        #expect(categoryUseCase.addCalled)
        #expect(sut.selectedCategory?.name == "Proyectos")
    }

    @Test func suggestionUnavailableReason_reflectsUseCase() {
        let suggestionUseCase = MockNoteSuggestionUseCase(isAvailable: false, unavailableReason: "Activá Apple Intelligence en Ajustes para ver sugerencias con IA")
        let sut = AddNoteViewModel(noteUseCase: MockNoteUseCase(), categoryUseCase: MockCategoryUseCase(), noteSuggestionUseCase: suggestionUseCase)

        #expect(sut.suggestionUnavailableReason == "Activá Apple Intelligence en Ajustes para ver sugerencias con IA")
    }

    @Test func valueDidChange_withShortText_doesNotTriggerSuggestion() {
        let suggestionUseCase = MockNoteSuggestionUseCase()
        let sut = AddNoteViewModel(noteUseCase: MockNoteUseCase(), categoryUseCase: MockCategoryUseCase(), noteSuggestionUseCase: suggestionUseCase)
        sut.value = "Corto"

        sut.valueDidChange()

        #expect(!suggestionUseCase.suggestCalled)
        #expect(sut.suggestion == nil)
    }
}
