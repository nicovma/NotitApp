//
//  NotitAppApp.swift
//  NotitApp
//
//  Created by Nicolas Valentini on 27/8/2026.
//

import SwiftUI
import SwiftData

@main
struct NotitAppApp: App {

    private let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: Note.self, Category.self)
        } catch {
            fatalError("No se pudo inicializar SwiftData: \(error)")
        }
        if ProcessInfo.processInfo.arguments.contains("--seed-screenshot-data") {
            Self.seedScreenshotData(into: modelContainer.mainContext)
        }
    }

    /// Fills the store with a few sample notes/categories so README/App
    /// Store screenshots don't have to ship the empty state. Only runs when
    /// explicitly launched with `--seed-screenshot-data` — never in a normal
    /// launch.
    private static func seedScreenshotData(into context: ModelContext) {
        let work = Category("Work", color: CategoryColor.blue.rawValue)
        let ideas = Category("Ideas", color: CategoryColor.purple.rawValue)
        let personal = Category("Personal", color: CategoryColor.green.rawValue)
        [work, ideas, personal].forEach(context.insert)

        let notes = [
            Note("Redesign review", value: "Walk through the onboarding flow and unify the button styles before Friday's demo.", category: work, createdAt: .now.addingTimeInterval(-3600)),
            Note("Weekend trip", value: "Pack the tent, check the weather forecast, book the campsite for Saturday.", category: personal, createdAt: .now.addingTimeInterval(-90000)),
            Note("Widget concept", value: "A small home-screen widget showing today's most recent note per category.", category: ideas, createdAt: .now.addingTimeInterval(-7200)),
        ]
        notes.forEach(context.insert)
    }

    var body: some Scene {
        WindowGroup {
            let root = CompositionRoot(modelContext: modelContainer.mainContext)
            RootTabView(root: root)
                // The Liquid Glass design is light-only by intent (pastel
                // background, hardcoded ink colors) — forcing light mode
                // here keeps every pushed screen legible regardless of the
                // system appearance, instead of patching adaptive colors
                // screen by screen.
                .preferredColorScheme(.light)
        }
    }
}
