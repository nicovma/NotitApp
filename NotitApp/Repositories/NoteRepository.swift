//
//  NoteRepository.swift
//  NotitApp
//
//  Created by Nicolas Valentini on 27/8/2026.
//
import Foundation

@MainActor
protocol NoteRepository {
    func save(_ note: Note) async throws -> Void
    func delete(_ note: Note) async throws -> Void
    func fetchAll() async throws -> [Note]
    func fetch(byCategory category: Category) async throws -> [Note]
}
