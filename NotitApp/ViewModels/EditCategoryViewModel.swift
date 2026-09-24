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

    init(category: Category, useCase: CategoryUseCase) {
        self.category = category
        self.name = category.name
        self.selectedColor = CategoryColor(rawValue: category.color) ?? .red
        self.useCase = useCase
    }

    /// Same rule as notes: no name, no save.
    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func saveChanges() async {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = String(localized: "El nombre no puede estar vacío")
            return
        }
        category.name = name
        category.color = selectedColor.rawValue
        do {
            try await useCase.update(category)
            didSave = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
