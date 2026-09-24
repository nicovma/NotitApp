//
//  CategoryNotesListView.swift
//  NotitApp
//
import Foundation
import SwiftUI
import SwiftData

struct CategoryNotesListView: View {

    @StateObject private var viewModel: CategoryNotesViewModel
    private let root: CompositionRoot
    @Binding private var path: NavigationPath
    @Environment(\.dismiss) private var dismiss

    init(_ viewModel: CategoryNotesViewModel, path: Binding<NavigationPath>, root: CompositionRoot) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _path = path
        self.root = root
    }

    private static let backdrop: [GlassBackdrop.Blob] = [
        .init(color: LiquidGlass.systemOrange, size: 230, blur: 75, opacity: 0.35, corner: .topLeading, inset: CGPoint(x: 65, y: 45)),
        .init(color: LiquidGlass.systemPurple, size: 270, blur: 85, opacity: 0.30, corner: .topTrailing, inset: CGPoint(x: 65, y: 105)),
        .init(color: LiquidGlass.systemBlue, size: 250, blur: 85, opacity: 0.28, corner: .bottomLeading, inset: CGPoint(x: 45, y: 305)),
    ]

    var body: some View {
        ZStack {
            GlassBackdrop(blobs: Self.backdrop)

            VStack(alignment: .leading, spacing: 0) {
                topBar
                    .padding(.bottom, 22)

                switch viewModel.state {
                case .idle, .loading:
                    ProgressView()

                case .loaded(let notes):
                    if notes.isEmpty {
                        emptyState
                    } else {
                        List {
                            ForEach(notes) { note in
                                NoteCard(note: note)
                                    .contentShape(Rectangle())
                                    .onTapGesture { path.append(note) }
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets(top: 7, leading: 0, bottom: 7, trailing: 0))
                            }
                            Color.clear.frame(height: 90)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }

                case .error(let message):
                    Text(message)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 40)
        }
        .navigationBarHidden(true)
        .hidesTabBarWhilePresented()
        .navigationDestination(for: Note.self) { note in
            NoteDetailView(note: note, root: root) {
                Task { await viewModel.delete(note) }
            }
        }
        .task {
            await viewModel.fetchNotes()
        }
    }

    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(LiquidGlass.ink)
                    .glassCircle()
            }
            .accessibilityLabel(Text("Volver"))

            Spacer()

            Text(viewModel.category.name)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(LiquidGlass.ink)

            Spacer()

            Color.clear.frame(width: 40, height: 40)
        }
    }

    private var emptyState: some View {
        VStack {
            Spacer()
            Text("Todavía no hay notas en esta categoría")
                .font(.system(size: 15))
                .foregroundStyle(LiquidGlass.inkSecondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    let container = try! ModelContainer(for: Note.self, Category.self, configurations: .init(isStoredInMemoryOnly: true))
    let category = Category("Trabajo", color: "BLUE")
    NavigationStack {
        CategoryNotesListView(
            CategoryNotesViewModel(category: category, useCase: MockNoteUseCase()),
            path: .constant(NavigationPath()),
            root: CompositionRoot(modelContext: container.mainContext)
        )
    }
    .environmentObject(TabBarVisibility())
}
