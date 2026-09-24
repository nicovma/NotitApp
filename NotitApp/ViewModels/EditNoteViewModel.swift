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

    init(note: Note, noteUseCase: NoteUseCase, categoryUseCase: CategoryUseCase) {
        self.note = note
        self.title = note.title
        self.value = note.value
        self.selectedCategory = note.category
        self.noteUseCase = noteUseCase
        self.categoryUseCase = categoryUseCase
    }

    /// Same rule as creating a note: no title, no category, no save.
    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedCategory != nil
    }

    func makeAddCategoryViewModel() -> AddCategoryViewModel {
        AddCategoryViewModel(useCase: categoryUseCase)
    }

    func loadCategories() async {
        do {
            categories = try await categoryUseCase.fetch()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func saveChanges() async {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = String(localized: "El título no puede estar vacío")
            return
        }
        guard let category = selectedCategory else {
            errorMessage = String(localized: "Elegí una categoría")
            return
        }
        note.title = title
        note.value = value
        note.category = category
        do {
            try await noteUseCase.update(note)
            didSave = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
