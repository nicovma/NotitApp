//
//  AddNoteViewModel.swift
//  NotitApp
//
//  Created by Nicolas Valentini on 27/8/2026.
//
import Foundation
import OSLog

@MainActor
final class AddNoteViewModel: ObservableObject {

    private let logger = Logger(subsystem: "nicovma.NotitApp", category: "AISuggestion")

    @Published private(set) var categories: [Category] = []
    @Published var title: String = ""
    @Published var value: String = ""
    @Published var selectedCategory: Category?
    @Published private(set) var errorMessage: String?
    @Published private(set) var didSave = false
    @Published private(set) var suggestion: NoteSuggestion?
    @Published private(set) var suggestedCategory: Category?
    @Published private(set) var isSuggesting = false

    private let noteUseCase: NoteUseCase
    private let categoryUseCase: CategoryUseCase
    private let noteSuggestionUseCase: NoteSuggestionUseCase
    private var debounceTask: Task<Void, Never>?

    init(noteUseCase: NoteUseCase, categoryUseCase: CategoryUseCase, noteSuggestionUseCase: NoteSuggestionUseCase) {
        self.noteUseCase = noteUseCase
        self.categoryUseCase = categoryUseCase
        self.noteSuggestionUseCase = noteSuggestionUseCase
    }

    /// Drives the "Guardar" button's enabled state so an incomplete note
    /// (no title, or no category — there's no default to fall back to once
    /// the user has none) can't be submitted in the first place, instead of
    /// only failing after the tap.
    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedCategory != nil
    }

    func makeAddCategoryViewModel() -> AddCategoryViewModel {
        AddCategoryViewModel(useCase: categoryUseCase)
    }

    var suggestionUnavailableReason: String? {
        noteSuggestionUseCase.unavailableReason
    }

    func loadCategories() async {
        do {
            categories = try await categoryUseCase.fetch()
            selectedCategory = selectedCategory ?? categories.first
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Called on every keystroke in the note body; debounces so we don't
    /// fire a suggestion request per character.
    func valueDidChange() {
        debounceTask?.cancel()
        guard value.count >= 15, noteSuggestionUseCase.isAvailable else {
            suggestion = nil
            suggestedCategory = nil
            return
        }
        debounceTask = Task {
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled else { return }
            await requestSuggestion()
        }
    }

    func requestSuggestion(avoiding previousSuggestion: NoteSuggestion? = nil) async {
        let sourceValue = value
        isSuggesting = true
        defer { isSuggesting = false }
        do {
            let result = try await noteSuggestionUseCase.suggest(for: sourceValue, existingCategories: categories, previousSuggestion: previousSuggestion)
            // The user may have kept typing while the model was thinking —
            // discard a suggestion that no longer matches the current text.
            guard sourceValue == value else { return }
            suggestion = result
            suggestedCategory = categories.first { $0.name.caseInsensitiveCompare(result.categoryName) == .orderedSame }
        } catch {
            // The suggestion is a bonus, not a requirement — the manual
            // flow keeps working untouched if the model fails.
            logger.debug("Suggestion request failed: \(error.localizedDescription)")
        }
    }

    /// Discards the current suggestion and asks the model again — the user's
    /// escape hatch when the first title/category guess doesn't fit.
    func requestAnotherSuggestion() {
        debounceTask?.cancel()
        let previousSuggestion = suggestion
        suggestion = nil
        suggestedCategory = nil
        Task { await requestSuggestion(avoiding: previousSuggestion) }
    }

    func applySuggestedTitle() {
        guard let suggestion else { return }
        title = suggestion.title
    }

    func applySuggestedCategory() async {
        guard let suggestion else { return }
        if let suggestedCategory {
            selectedCategory = suggestedCategory
            return
        }
        do {
            let newCategory = Category(suggestion.categoryName, color: CategoryColor.allCases.randomElement()?.rawValue ?? CategoryColor.blue.rawValue)
            try await categoryUseCase.add(newCategory)
            await loadCategories()
            selectedCategory = categories.first { $0.id == newCategory.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createNote() async {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = String(localized: "El título no puede estar vacío")
            return
        }
        guard let category = selectedCategory else {
            errorMessage = String(localized: "Elegí una categoría")
            return
        }
        let note = Note(title, value: value, category: category, createdAt: .now)
        do {
            try await noteUseCase.add(note)
            didSave = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
