//
//  TabBarVisibility.swift
//  NotitApp
//
import SwiftUI

/// Shared between `RootTabView` and any screen pushed on top of a list, so
/// the floating tab bar (an overlay outside both `NavigationStack`s) hides
/// itself while a detail/creation screen is on top instead of floating over
/// content — and over the keyboard — that has nothing to do with tabs.
@MainActor
final class TabBarVisibility: ObservableObject {
    @Published var isHidden = false
}

private struct HidesTabBarWhilePresented: ViewModifier {
    @EnvironmentObject private var tabBarVisibility: TabBarVisibility

    func body(content: Content) -> some View {
        content
            .onAppear { tabBarVisibility.isHidden = true }
            .onDisappear { tabBarVisibility.isHidden = false }
    }
}

extension View {
    /// Marks a pushed (non-root) screen as one that should hide the floating
    /// tab bar for as long as it's on screen.
    func hidesTabBarWhilePresented() -> some View {
        modifier(HidesTabBarWhilePresented())
    }
}
