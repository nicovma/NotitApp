//
//  CategoryRepository.swift
//  NotitApp
//
//  Created by Nicolas Valentini on 27/8/2026.
//
import Foundation

@MainActor
protocol CategoryRepository {
    func save(_ category: Category) async throws -> Void
    func delete(_ category: Category) async throws -> Void
    func fetchAll() async throws -> [Category]
}
