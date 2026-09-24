//
//  CategoryUseCase.swift
//  NotitApp
//
//  Created by Nicolas Valentini on 27/8/2026.
//
import Foundation

@MainActor
protocol CategoryUseCase {
    func add(_ category: Category) async throws -> Void
    func update(_ category: Category) async throws -> Void
    func delete(_ category: Category) async throws -> Void
    func fetch() async throws -> [Category]
}
