//
//  FirebaseAnalyticsLogger.swift
//  NotitApp
//
import FirebaseAnalytics
import FirebaseCrashlytics

struct FirebaseAnalyticsLogger: AnalyticsLogging {
    func logEvent(_ name: String, parameters: [String: Any]?) {
        Analytics.logEvent(name, parameters: parameters)
    }

    func recordError(_ error: Error) {
        Crashlytics.crashlytics().record(error: error)
    }

    func setUserProperty(_ value: String?, forName name: String) {
        Analytics.setUserProperty(value, forName: name)
    }
}
