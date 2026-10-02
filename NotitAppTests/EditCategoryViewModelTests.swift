import Testing
@testable import NotitApp

@MainActor
struct EditCategoryViewModelTests {

    @Test func init_prefillsFieldsFromCategory() async {
        let category = Category("Trabajo", color: "BLUE")
        let sut = EditCategoryViewModel(category: category, useCase: MockCategoryUseCase())

        #expect(sut.name == "Trabajo")
        #expect(sut.selectedColor == .blue)
    }

    @Test func canSave_isFalse_whenNameIsBlank() async {
        let category = Category("Trabajo", color: "BLUE")
        let sut = EditCategoryViewModel(category: category, useCase: MockCategoryUseCase())
        sut.name = "   "

        #expect(!sut.canSave)
    }

    @Test func canSave_isTrue_whenNameIsPresent() async {
        let category = Category("Trabajo", color: "BLUE")
        let sut = EditCategoryViewModel(category: category, useCase: MockCategoryUseCase())

        #expect(sut.canSave)
    }

    @Test func saveChanges_withEmptyName_setsErrorAndDoesNotSave() async {
        let useCase = MockCategoryUseCase()
        let category = Category("Trabajo", color: "BLUE")
        let sut = EditCategoryViewModel(category: category, useCase: useCase)
        sut.name = "   "

        await sut.saveChanges()

        #expect(sut.errorMessage != nil)
        #expect(!useCase.updateCalled)
        #expect(!sut.didSave)
    }

    @Test func saveChanges_valid_updatesCategoryAndMarksDidSave() async {
        let useCase = MockCategoryUseCase()
        let category = Category("Trabajo", color: "BLUE")
        let sut = EditCategoryViewModel(category: category, useCase: useCase)
        sut.name = "Personal"
        sut.selectedColor = .green

        await sut.saveChanges()

        #expect(useCase.updateCalled)
        #expect(sut.didSave)
        #expect(sut.errorMessage == nil)
        #expect(category.name == "Personal")
        #expect(category.color == CategoryColor.green.rawValue)
    }

    @Test func saveChanges_trimsNameBeforeSaving() async {
        let category = Category("Trabajo", color: "BLUE")
        let sut = EditCategoryViewModel(category: category, useCase: MockCategoryUseCase())
        sut.name = "  Laburo  "

        await sut.saveChanges()

        #expect(category.name == "Laburo")
    }

    @Test func saveChanges_whenUpdateFails_restoresOriginalCategoryAndRecordsError() async {
        let category = Category("Trabajo", color: "BLUE")
        let analytics = SpyAnalyticsLogger()
        let sut = EditCategoryViewModel(category: category, useCase: ThrowingCategoryUseCase(), analytics: analytics)
        sut.name = "Cambiada"
        sut.selectedColor = .red

        await sut.saveChanges()

        #expect(category.name == "Trabajo")
        #expect(category.color == "BLUE")
        #expect(analytics.recordedErrorCount == 1)
        #expect(sut.errorMessage != nil)
        #expect(!sut.didSave)
    }
}
