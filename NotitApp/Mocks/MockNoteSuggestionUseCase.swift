//
//  MockNoteSuggestionUseCase.swift
//  NotitApp
//
//  Created by Nicolas Valentini on 16/9/2026.
//
import Foundation

#if DEBUG
final class MockNoteSuggestionUseCase: NoteSuggestionUseCase {
    var isAvailable: Bool
    var unavailableReason: String?
    var result: Result<NoteSuggestion, Error>
    private(set) var suggestCalled = false

    init(isAvailable: Bool = true, unavailableReason: String? = nil, result: Result<NoteSuggestion, Error> = .success(NoteSuggestion(title: "Lista del súper", categoryName: "Compras", isNewCategory: false))) {
        self.isAvailable = isAvailable
        self.unavailableReason = unavailableReason
        self.result = result
    }

    func suggest(for text: String, existingCategories: [Category], previousSuggestion: NoteSuggestion?) async throws -> NoteSuggestion {
        suggestCalled = true
        return try result.get()
    }
}
#endif
