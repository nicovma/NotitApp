//
//  CompositionRoot.swift
//  NotitApp
//
//  Created by Nicolas Valentini on 27/8/2026.
//
import Foundation
import SwiftData

@MainActor
final class CompositionRoot {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func makeNoteListViewModel() -> NoteListViewModel {
        NoteListViewModel(useCase: makeNoteUseCase())
    }

    func makeAddNoteViewModel() -> AddNoteViewModel {
        AddNoteViewModel(noteUseCase: makeNoteUseCase(), categoryUseCase: makeCategoryUseCase(), noteSuggestionUseCase: makeNoteSuggestionUseCase())
    }

    func makeEditNoteViewModel(for note: Note) -> EditNoteViewModel {
        EditNoteViewModel(note: note, noteUseCase: makeNoteUseCase(), categoryUseCase: makeCategoryUseCase())
    }

    func makeCategoryListViewModel() -> CategoryListViewModel {
        CategoryListViewModel(useCase: makeCategoryUseCase())
    }

    func makeAddCategoryViewModel() -> AddCategoryViewModel {
        AddCategoryViewModel(useCase: makeCategoryUseCase())
    }

    func makeEditCategoryViewModel(for category: Category) -> EditCategoryViewModel {
        EditCategoryViewModel(category: category, useCase: makeCategoryUseCase())
    }

    func makeCategoryNotesViewModel(for category: Category) -> CategoryNotesViewModel {
        CategoryNotesViewModel(category: category, useCase: makeNoteUseCase())
    }

    private func makeNoteUseCase() -> NoteUseCase {
        DefaultNoteUseCase(repository: SwiftDataNoteRepository(context: modelContext))
    }

    private func makeCategoryUseCase() -> CategoryUseCase {
        DefaultCategoryUseCase(repository: SwiftDataCategoryRepository(context: modelContext))
    }

    private func makeNoteSuggestionUseCase() -> NoteSuggestionUseCase {
        DefaultNoteSuggestionUseCase()
    }
}
