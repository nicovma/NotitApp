//
//  NoOpAnalyticsLogger.swift
//  NotitApp
//
import Foundation

/// Used in tests and previews (and as every view model's default init
/// parameter) so nothing needs a live Firebase configuration to run.
struct NoOpAnalyticsLogger: AnalyticsLogging {
    func logEvent(_ name: String, parameters: [String: Any]?) {}
    func recordError(_ error: Error) {}
    func setUserProperty(_ value: String?, forName name: String) {}
}
