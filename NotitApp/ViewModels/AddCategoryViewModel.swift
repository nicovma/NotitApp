//
//  AddCategoryViewModel.swift
//  NotitApp
//
//  Created by Nicolas Valentini on 27/8/2026.
//
import Foundation

@MainActor
final class AddCategoryViewModel: ObservableObject {

    @Published var name: String = ""
    @Published var selectedColor: CategoryColor = .red
    @Published private(set) var errorMessage: String?
    @Published private(set) var didSave = false

    private let useCase: CategoryUseCase

    init(useCase: CategoryUseCase) {
        self.useCase = useCase
    }

    /// Same rule as notes: no name, no save.
    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func createCategory() async {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = String(localized: "El nombre no puede estar vacío")
            return
        }
        let category = Category(name, color: selectedColor.rawValue)
        do {
            try await useCase.add(category)
            didSave = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
