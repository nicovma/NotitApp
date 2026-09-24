//
//  SwiftDataCategoryRepository.swift
//  NotitApp
//
//  Created by Nicolas Valentini on 27/8/2026.
//
import Foundation
import SwiftData

@MainActor
final class SwiftDataCategoryRepository: CategoryRepository {
    
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }
    
    func save(_ category: Category) async throws {
        context.insert(category)
        try context.save()
    }
    
    func delete(_ category: Category) async throws {
        context.delete(category)
        try context.save()
    }
    
    func fetchAll() async throws -> [Category] {
        let descriptor = FetchDescriptor<Category>(sortBy: [SortDescriptor(\.name)])
        return try context.fetch(descriptor)
    }
}
