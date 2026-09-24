//
//  NoteSuggestionUseCase.swift
//  NotitApp
//
//  Created by Nicolas Valentini on 16/9/2026.
//
import Foundation

@MainActor
protocol NoteSuggestionUseCase {
    var isAvailable: Bool { get }
    /// Human-readable reason the suggestion isn't available, or nil when it is.
    var unavailableReason: String? { get }
    func suggest(for text: String, existingCategories: [Category], previousSuggestion: NoteSuggestion?) async throws -> NoteSuggestion
}
