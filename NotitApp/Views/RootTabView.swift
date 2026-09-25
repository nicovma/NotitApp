//
//  RootTabView.swift
//  NotitApp
//
import SwiftUI

struct RootTabView: View {
    let root: CompositionRoot
    @State private var selection: AppTab = .notes
    @StateObject private var tabBarVisibility = TabBarVisibility()
    @StateObject private var categoryListViewModel: CategoryListViewModel

    init(root: CompositionRoot) {
        self.root = root
        _categoryListViewModel = StateObject(wrappedValue: root.makeCategoryListViewModel())
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selection) {
                NotesListView(root.makeNoteListViewModel(), root: root)
                    .tag(AppTab.notes)
                    .toolbar(.hidden, for: .tabBar)

                CategoriesListView(categoryListViewModel, root: root)
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
        .onChange(of: selection) {
            // CategoriesListView's own .task only runs once per app
            // lifetime (RootTabView keeps both tabs alive inside the same
            // TabView) — without this, a note created from the Notes tab
            // never refreshes the note count shown per category here.
            if selection == .categories {
                Task { await categoryListViewModel.fetchCategories() }
            }
        }
    }
}
