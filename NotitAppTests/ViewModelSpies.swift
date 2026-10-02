@testable import NotitApp

final class SpyAnalyticsLogger: AnalyticsLogging {
    private(set) var loggedEvents: [String] = []
    private(set) var recordedErrorCount = 0

    func logEvent(_ name: String, parameters: [String: Any]?) {
        loggedEvents.append(name)
    }

    func recordError(_ error: Error) {
        recordedErrorCount += 1
    }

    func setUserProperty(_ value: String?, forName name: String) {}
}

/// Holds every `suggest` call open until the test resumes it, so overlapping
/// suggestion requests can be finished in a controlled order.
final class GatedNoteSuggestionUseCase: NoteSuggestionUseCase {
    var isAvailable: Bool { true }
    var unavailableReason: String? { nil }
    private(set) var pending: [CheckedContinuation<NoteSuggestion, Error>] = []

    func suggest(for text: String, existingCategories: [NotitApp.Category], previousSuggestion: NoteSuggestion?) async throws -> NoteSuggestion {
        try await withCheckedThrowingContinuation { pending.append($0) }
    }

    func resume(_ index: Int, with suggestion: NoteSuggestion) {
        pending[index].resume(returning: suggestion)
    }

    func waitForPendingCount(_ count: Int) async {
        while pending.count < count { await Task.yield() }
    }
}
