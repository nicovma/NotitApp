//
//  DefaultNoteUseCase.swift
//  NotitApp
//
//  Created by Nicolas Valentini on 27/8/2026.
//
import Foundation

@MainActor
final class DefaultNoteUseCase: NoteUseCase {
    
    private let repository: NoteRepository
    
    init(repository: NoteRepository) {
        self.repository = repository
    }
    
    func add(_ note: Note) async throws {
        try await self.repository.save(note)

    }

    func update(_ note: Note) async throws {
        note.updatedAt = .now
        try await self.repository.save(note)
    }

    func delete(_ note: Note) async throws {
        try await self.repository.delete(note)
    }
    
    func fetch() async throws -> [Note] {
        let notes = try await repository.fetchAll()
        return notes
    }

    func fetch(byCategory category: Category) async throws -> [Note] {
        try await repository.fetch(byCategory: category)
    }

}
