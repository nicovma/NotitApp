//
//  NoteUseCase.swift
//  NotitApp
//
//  Created by Nicolas Valentini on 27/8/2026.
//
import Foundation

@MainActor
protocol NoteUseCase {
    func add(_ note: Note) async throws -> Void
    func update(_ note: Note) async throws -> Void
    func delete(_ note: Note) async throws -> Void
    func fetch() async throws -> [Note]
    func fetch(byCategory category: Category) async throws -> [Note]
}

