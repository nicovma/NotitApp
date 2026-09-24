//
//  RootTabView.swift
//  NotitApp
//
import SwiftUI

struct RootTabView: View {
    let root: CompositionRoot
    @State private var selection: AppTab = .notes
    @StateObject private var tabBarVisibility = TabBarVisibility()

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selection) {
                NotesListView(root.makeNoteListViewModel(), root: root)
                    .tag(AppTab.notes)
                    .toolbar(.hidden, for: .tabBar)

                CategoriesListView(root.makeCategoryListViewModel(), root: root)
                    .tag(AppTab.categories)
                    .toolbar(.hidden, for: .tabBar)
            }
            .environmentObject(tabBarVisibility)

            if !tabBarVisibility.isHidden {
                LiquidGlassTabBar(selection: $selection)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: tabBarVisibility.isHidden)
    }
}
