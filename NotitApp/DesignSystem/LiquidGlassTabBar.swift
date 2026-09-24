//
//  LiquidGlassTabBar.swift
//  NotitApp
//
import SwiftUI
import UIKit

enum AppTab {
    case notes
    case categories
}

/// The floating glass tab bar shared by both top-level tabs. Lives once at
/// the `RootTabView` level, overlaid on top of a real `TabView` — the
/// screens themselves don't own it, so switching tabs never re-triggers
/// their `.task`/fetch (a `NavigationLink` push, the previous approach, was
/// creating a fresh `CategoriesListView` — and re-fetching — on every tap).
struct LiquidGlassTabBar: View {
    @Binding var selection: AppTab

    var body: some View {
        HStack(spacing: 8) {
            tabButton(.notes, icon: "note.text", title: "Notas")
            tabButton(.categories, icon: "heart.text.square", title: "Categorías")
        }
        .padding(.horizontal, 8)
        .frame(height: 64)
        .glassSurface(cornerRadius: 32, borderOpacity: 0.75)
    }

    private func tabButton(_ tab: AppTab, icon: String, title: LocalizedStringKey) -> some View {
        let isSelected = selection == tab
        return Button {
            guard selection != tab else { return }
            let haptic = UIImpactFeedbackGenerator(style: .light)
            haptic.impactOccurred()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                selection = tab
            }
        } label: {
            HStack(spacing: 7) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: isSelected ? .semibold : .regular))
                Text(title).font(.system(size: 13, weight: isSelected ? .bold : .semibold))
            }
            .foregroundStyle(isSelected ? LiquidGlass.primary : LiquidGlass.inkSecondary)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity)
            .contentShape(Capsule())
            .background(isSelected ? LiquidGlass.primary.opacity(0.14) : Color.clear, in: Capsule())
        }
        .buttonStyle(.plain)
        // A custom tab bar doesn't inherit TabView's built-in "tab, selected"
        // semantics — combine collapses icon+label into one stop and the
        // trait restores the selected-state announcement a real TabView
        // would give for free.
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}
