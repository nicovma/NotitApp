//
//  DefaultCategoryUseCase.swift
//  NotitApp
//
//  Created by Nicolas Valentini on 27/8/2026.
//
import Foundation

@MainActor
final class DefaultCategoryUseCase: CategoryUseCase {
    
    private let repository: CategoryRepository
    
    init(repository: CategoryRepository) {
        self.repository = repository
    }
    
    func add(_ category: Category) async throws {
        try await save(category)
    }

    func update(_ category: Category) async throws {
        try await save(category)
    }

    private func save(_ category: Category) async throws {
        try await repository.save(category)
    }

    func delete(_ category: Category) async throws {
        try await repository.delete(category)
    }
    
    func fetch() async throws -> [Category] {
        let categories = try await repository.fetchAll()
        return categories
    }
}
