import Testing
@testable import NotitApp

@MainActor
struct AddCategoryViewModelTests {

    @Test func createCategory_withEmptyName_setsErrorAndDoesNotSave() async {
        let useCase = MockCategoryUseCase()
        let sut = AddCategoryViewModel(useCase: useCase)
        sut.name = "   "

        await sut.createCategory()

        #expect(sut.errorMessage != nil)
        #expect(!useCase.addCalled)
        #expect(!sut.didSave)
    }

    @Test func createCategory_valid_savesAndMarksDidSave() async {
        let useCase = MockCategoryUseCase()
        let sut = AddCategoryViewModel(useCase: useCase)
        sut.name = "Trabajo"
        sut.selectedColor = .blue

        await sut.createCategory()

        #expect(useCase.addCalled)
        #expect(sut.didSave)
        #expect(sut.errorMessage == nil)
    }
}
