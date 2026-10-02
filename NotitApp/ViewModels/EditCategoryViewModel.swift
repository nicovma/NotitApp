//
//  EditCategoryViewModel.swift
//  NotitApp
//
import Foundation

@MainActor
final class EditCategoryViewModel: ObservableObject {

    let category: Category

    @Published var name: String
    @Published var selectedColor: CategoryColor
    @Published private(set) var errorMessage: String?
    @Published private(set) var didSave = false

    private let useCase: CategoryUseCase
    private let analytics: AnalyticsLogging

    init(category: Category, useCase: CategoryUseCase, analytics: AnalyticsLogging = NoOpAnalyticsLogger()) {
        self.category = category
        self.name = category.name
        self.selectedColor = CategoryColor(rawValue: category.color) ?? .red
        self.useCase = useCase
        self.analytics = analytics
    }

    /// Same rule as notes: no name, no save.
    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func saveChanges() async {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            errorMessage = String(localized: "El nombre no puede estar vacío")
            return
        }
        // Same rollback rule as EditNoteViewModel: the live model only keeps
        // the edits if the update actually succeeded.
        let original = (name: category.name, color: category.color)
        category.name = trimmedName
        category.color = selectedColor.rawValue
        do {
            try await useCase.update(category)
            didSave = true
        } catch {
            category.name = original.name
            category.color = original.color
            analytics.recordError(error)
            errorMessage = error.localizedDescription
        }
    }
}
