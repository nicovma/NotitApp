//
//  SwiftDataNoteRepository.swift
//  NotitApp
//
//  Created by Nicolas Valentini on 27/8/2026.
//
import Foundation
import SwiftData

@MainActor
final class SwiftDataNoteRepository: NoteRepository {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func save(_ note: Note) async throws {
        context.insert(note)
        try context.save()
    }

    func delete(_ note: Note) async throws {
        context.delete(note)
        try context.save()
    }

    func fetchAll() async throws -> [Note] {
        let descriptor = FetchDescriptor<Note>(sortBy: [SortDescriptor(\.updatedAt, order: .reverse)])
        return try context.fetch(descriptor)
    }

    func fetch(byCategory category: Category) async throws -> [Note] {
        let categoryID = category.id
        let descriptor = FetchDescriptor<Note>(
            predicate: #Predicate { $0.category.id == categoryID },
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }
}
