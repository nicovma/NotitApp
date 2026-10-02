//
//  EditNoteViewModel.swift
//  NotitApp
//
import Foundation

@MainActor
final class EditNoteViewModel: ObservableObject {

    let note: Note

    @Published private(set) var categories: [Category] = []
    @Published var title: String
    @Published var value: String
    @Published var selectedCategory: Category?
    @Published private(set) var errorMessage: String?
    @Published private(set) var didSave = false

    private let noteUseCase: NoteUseCase
    private let categoryUseCase: CategoryUseCase
    private let analytics: AnalyticsLogging

    init(note: Note, noteUseCase: NoteUseCase, categoryUseCase: CategoryUseCase, analytics: AnalyticsLogging = NoOpAnalyticsLogger()) {
        self.note = note
        self.title = note.title
        self.value = note.value
        self.selectedCategory = note.category
        self.noteUseCase = noteUseCase
        self.categoryUseCase = categoryUseCase
        self.analytics = analytics
    }

    /// Same rule as creating a note: no title, no category, no save.
    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedCategory != nil
    }

    func makeAddCategoryViewModel() -> AddCategoryViewModel {
        AddCategoryViewModel(useCase: categoryUseCase, analytics: analytics)
    }

    func loadCategories() async {
        do {
            categories = try await categoryUseCase.fetch()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func saveChanges() async {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            errorMessage = String(localized: "El título no puede estar vacío")
            return
        }
        guard let category = selectedCategory else {
            errorMessage = String(localized: "Elegí una categoría")
            return
        }
        // `note` is a live SwiftData model: mutate it only for the save attempt
        // and roll back on failure, so a failed update doesn't leave edits that
        // were never persisted showing up everywhere else in the app.
        let original = (title: note.title, value: note.value, category: note.category)
        note.title = trimmedTitle
        note.value = value
        note.category = category
        do {
            try await noteUseCase.update(note)
            didSave = true
        } catch {
            note.title = original.title
            note.value = original.value
            note.category = original.category
            analytics.recordError(error)
            errorMessage = error.localizedDescription
        }
    }
}
