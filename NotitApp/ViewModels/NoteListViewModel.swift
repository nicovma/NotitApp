//
//  NoteListViewModel.swift
//  NotitApp
//
//  Created by Nicolas Valentini on 27/8/2026.
//
import Foundation

@MainActor
final class NoteListViewModel: ObservableObject {
    
    @Published private(set) var state: ViewModelState<[Note]> = .idle
    
    private let useCase: NoteUseCase
    
    init(useCase: NoteUseCase) {
        self.useCase = useCase
    }
    
    
    func fetchNotes() async {
        state = .loading
        do {
            let notes = try await useCase.fetch()
            state = .loaded(notes)
        } catch {
            state = .error(error.localizedDescription)
        }
        
    }
    
    func delete(_ note: Note) async {
        state = .loading
        do {
            try await useCase.delete(note)
            let notes = try await useCase.fetch()
            state = .loaded(notes)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
