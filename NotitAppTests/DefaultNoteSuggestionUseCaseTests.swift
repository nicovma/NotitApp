import Testing
@testable import NotitApp

/// Covers the prompt the use case sends to Apple's on-device model. The
/// `LanguageModelSession` call itself is out of scope: there's no seam to fake
/// `SystemLanguageModel`, and CI runners don't have Apple Intelligence.
@MainActor
struct DefaultNoteSuggestionUseCaseTests {

    @Test func makePrompt_withoutCategories_saysThereAreNone() {
        let prompt = DefaultNoteSuggestionUseCase.makePrompt(for: "Comprar leche", existingCategories: [], previousSuggestion: nil)

        #expect(prompt.contains("Categorías existentes: ninguna"))
        #expect(prompt.contains("Comprar leche"))
    }

    @Test func makePrompt_listsExistingCategoryNames() {
        let categories = [Category("Compras", color: "RED"), Category("Trabajo", color: "BLUE")]

        let prompt = DefaultNoteSuggestionUseCase.makePrompt(for: "Comprar leche", existingCategories: categories, previousSuggestion: nil)

        #expect(prompt.contains("Categorías existentes: Compras, Trabajo"))
    }

    @Test func makePrompt_withoutPreviousSuggestion_doesNotAskForAnAlternative() {
        let prompt = DefaultNoteSuggestionUseCase.makePrompt(for: "Comprar leche", existingCategories: [], previousSuggestion: nil)

        #expect(!prompt.contains("Ya sugeriste"))
    }

    @Test func makePrompt_withPreviousSuggestion_asksToAvoidRepeatingIt() {
        let previous = NoteSuggestion(title: "Leche", categoryName: "Compras", isNewCategory: false)

        let prompt = DefaultNoteSuggestionUseCase.makePrompt(for: "Comprar leche", existingCategories: [], previousSuggestion: previous)

        #expect(prompt.contains("título=\"Leche\""))
        #expect(prompt.contains("categoría=\"Compras\""))
        #expect(prompt.contains("no repitas ese título ni esa categoría"))
    }
}
