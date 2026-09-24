//
//  CategoryNotesViewModel.swift
//  NotitApp
//
import Foundation

@MainActor
final class CategoryNotesViewModel: ObservableObject {

    let category: Category

    @Published private(set) var state: ViewModelState<[Note]> = .idle

    private let useCase: NoteUseCase

    init(category: Category, useCase: NoteUseCase) {
        self.category = category
        self.useCase = useCase
    }

    func fetchNotes() async {
        state = .loading
        do {
            let notes = try await useCase.fetch(byCategory: category)
            state = .loaded(notes)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func delete(_ note: Note) async {
        state = .loading
        do {
            try await useCase.delete(note)
            let notes = try await useCase.fetch(byCategory: category)
            state = .loaded(notes)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
