//
//  NotesListView.swift
//  NotitApp
//
//  Created by Nicolas Valentini on 27/8/2026.
//
import Foundation
import SwiftUI
import SwiftData

struct NotesListView: View {

    @StateObject private var viewModel: NoteListViewModel
    private let root: CompositionRoot
    @State private var searchText = ""
    @State private var path: [Note] = []
    @State private var isAddingNote = false
    @State private var notePendingDeletion: Note?
    @FocusState private var isSearchFocused: Bool

    init(_ vm: NoteListViewModel, root: CompositionRoot) {
        _viewModel = StateObject(wrappedValue: vm)
        self.root = root
    }

    private static let backdrop: [GlassBackdrop.Blob] = [
        .init(color: LiquidGlass.systemOrange, size: 230, blur: 75, opacity: 0.35, corner: .topLeading, inset: CGPoint(x: 65, y: 45)),
        .init(color: LiquidGlass.systemPurple, size: 270, blur: 85, opacity: 0.30, corner: .topTrailing, inset: CGPoint(x: 65, y: 105)),
        .init(color: LiquidGlass.systemBlue, size: 250, blur: 85, opacity: 0.28, corner: .bottomLeading, inset: CGPoint(x: 45, y: 305)),
        .init(color: LiquidGlass.systemGreen, size: 230, blur: 75, opacity: 0.22, corner: .bottomTrailing, inset: CGPoint(x: 65, y: 45)),
    ]

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                GlassBackdrop(blobs: Self.backdrop)

                switch viewModel.state {
                case .idle, .loading:
                    ProgressView()

                case .loaded(let notes):
                    let filtered = notes.filter {
                        searchText.isEmpty || $0.title.localizedCaseInsensitiveContains(searchText)
                    }
                    VStack(spacing: 0) {
                        header
                        searchField
                        if filtered.isEmpty {
                            emptyState
                                .contentShape(Rectangle())
                                .onTapGesture { isSearchFocused = false }
                        } else {
                            List {
                                ForEach(filtered) { note in
                                    NoteCard(note: note)
                                        .contentShape(Rectangle())
                                        .onTapGesture { path.append(note) }
                                        .listRowBackground(Color.clear)
                                        .listRowSeparator(.hidden)
                                        .listRowInsets(EdgeInsets(top: 7, leading: 0, bottom: 7, trailing: 0))
                                        .swipeActions {
                                            // Sin `role: .destructive`, ver CategoriesListView: con ese
                                            // role iOS anima la fila como ya borrada antes de mostrar la
                                            // confirmación.
                                            Button("Eliminar") {
                                                notePendingDeletion = note
                                            }
                                            .tint(LiquidGlass.systemRed)
                                        }
                                }
                                Color.clear.frame(height: 90)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                            }
                            .listStyle(.plain)
                            .scrollContentBackground(.hidden)
                            .scrollDismissesKeyboard(.immediately)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 60)
                    .navigationDestination(for: Note.self) { note in
                        NoteDetailView(note: note, root: root) {
                            Task { await viewModel.delete(note) }
                        }
                    }

                case .error(let messageError):
                    Text(messageError)
                }
            }
            .navigationBarHidden(true)
            .task {
                await viewModel.fetchNotes()
            }
        }
        .sheet(isPresented: $isAddingNote) {
            NavigationStack {
                AddNoteView(root.makeAddNoteViewModel())
            }
        }
        // .alert, no .confirmationDialog: mismo bug de iOS 26 documentado en
        // CategoriesListView (confirmationDialog puede perder el botón Cancelar).
        .alert(
            notePendingDeletion.map { String(format: String(localized: "¿Eliminar \"%@\"?"), $0.title) } ?? "",
            isPresented: Binding(
                get: { notePendingDeletion != nil },
                set: { isPresented in if !isPresented { notePendingDeletion = nil } }
            )
        ) {
            Button("Eliminar", role: .destructive) {
                if let note = notePendingDeletion {
                    Task { await viewModel.delete(note) }
                }
                notePendingDeletion = nil
            }
            Button("Cancelar", role: .cancel) {
                notePendingDeletion = nil
            }
        } message: {
            Text("Esta acción no se puede deshacer.")
        }
        .onChange(of: isAddingNote) {
            // NotesListView vive todo el ciclo de vida de la app dentro del
            // TabView, así que su .task inicial no vuelve a correr al volver
            // de "Nueva nota" — sin este refetch explícito, la nota se guarda
            // pero el listado se queda con el estado viejo.
            if !isAddingNote {
                Task { await viewModel.fetchNotes() }
            }
        }
    }

    private var header: some View {
        HStack {
            Text("Notas")
                .font(.system(size: 34, weight: .heavy))
                .foregroundStyle(LiquidGlass.ink)
            Spacer()
            Button {
                isAddingNote = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(LiquidGlass.primary)
                    .glassCircle()
            }
            .accessibilityLabel(Text("Nueva nota"))
        }
        .padding(.bottom, 16)
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(LiquidGlass.inkSecondary)
            TextField("Buscar", text: $searchText)
                .foregroundStyle(LiquidGlass.ink)
                .focused($isSearchFocused)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .glassSurface(cornerRadius: 14)
        .padding(.bottom, 20)
    }

    private var emptyState: some View {
        VStack {
            Spacer()
            Text("No hay notas todavía")
                .font(.system(size: 15))
                .foregroundStyle(LiquidGlass.inkSecondary)
            Spacer()
        }
    }

}

struct NoteCard: View {
    let note: Note

    var body: some View {
        let color = CategoryColor(rawValue: note.category.color)?.swiftUIColor ?? .gray

        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 6) {
                    Circle().fill(color).frame(width: 6, height: 6)
                    Text(note.category.name)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(color)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(color.opacity(0.14), in: Capsule())

                Spacer()

                Text(note.updatedAt.relativeDescription)
                    .font(.system(size: 12))
                    .foregroundStyle(LiquidGlass.inkSecondary)
            }

            Text(note.title)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(LiquidGlass.ink)

            Text(note.value)
                .font(.system(size: 14))
                .foregroundStyle(LiquidGlass.inkSecondary)
                .lineLimit(2)
        }
        .padding(16)
        .padding(.leading, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            // The category color bar sits flush against the card's left
            // edge, full height, clipped by the same rounded shape as the
            // glass fill — matching the source design's `overflow:hidden`
            // container exactly, instead of a separate floating bar.
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.white.opacity(0.16))
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                Rectangle().fill(color).frame(width: 4)
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(.white.opacity(0.7), lineWidth: 1)
        )
        .compositingGroup()
        .shadow(color: .black.opacity(0.07), radius: 16, x: 0, y: 8)
        // Without this, VoiceOver stops on category, date, title and body
        // as four separate swipes per card instead of one.
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    let container = try! ModelContainer(for: Note.self, Category.self, configurations: .init(isStoredInMemoryOnly: true))
    NotesListView(
        NoteListViewModel(useCase: MockNoteUseCase()),
        root: CompositionRoot(modelContext: container.mainContext)
    )
    .environmentObject(TabBarVisibility())
}
