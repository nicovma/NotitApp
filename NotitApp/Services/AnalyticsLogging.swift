//
//  AnalyticsLogging.swift
//  NotitApp
//
import Foundation

/// Keeps every call site decoupled from the concrete analytics SDK —
/// `FirebaseAnalyticsLogger`/`NoOpAnalyticsLogger` are the only two files
/// besides `CompositionRoot` allowed to import Firebase.
protocol AnalyticsLogging {
    func logEvent(_ name: String, parameters: [String: Any]?)
    func recordError(_ error: Error)
    func setUserProperty(_ value: String?, forName name: String)
}
