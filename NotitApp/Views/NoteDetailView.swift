//
//  NoteDetailView.swift
//  NotitApp
//
//  Created by Nicolas Valentini on 27/8/2026.
//
import Foundation
import SwiftUI
import SwiftData

struct NoteDetailView: View {

    let note: Note
    let root: CompositionRoot
    let onDelete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var isEditing = false
    @State private var isConfirmingDelete = false

    private static let backdrop: [GlassBackdrop.Blob] = [
        .init(color: LiquidGlass.systemBlue, size: 230, blur: 75, opacity: 0.30, corner: .topLeading, inset: CGPoint(x: 65, y: 45)),
        .init(color: LiquidGlass.systemPurple, size: 270, blur: 85, opacity: 0.25, corner: .topTrailing, inset: CGPoint(x: 65, y: 105)),
        .init(color: LiquidGlass.systemGreen, size: 230, blur: 75, opacity: 0.20, corner: .bottomTrailing, inset: CGPoint(x: 65, y: 45)),
    ]

    var body: some View {
        let color = CategoryColor(rawValue: note.category.color)?.swiftUIColor ?? .gray

        ZStack {
            GlassBackdrop(blobs: Self.backdrop)

            VStack(alignment: .leading, spacing: 0) {
                topBar
                    .padding(.bottom, 18)

                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 10) {
                        HStack(spacing: 6) {
                            Circle().fill(color).frame(width: 6, height: 6)
                                .accessibilityHidden(true)
                            Text(note.category.name)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(color)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(color.opacity(0.14), in: Capsule())

                        Text(note.createdAt.relativeDescription)
                            .font(.system(size: 13))
                            .foregroundStyle(LiquidGlass.inkSecondary)
                    }
                    .padding(.bottom, 16)
                    .accessibilityElement(children: .combine)

                    Text(note.title)
                        .font(.system(size: 26, weight: .heavy))
                        .foregroundStyle(LiquidGlass.ink)
                        .padding(.bottom, 16)

                    Rectangle()
                        .fill(LiquidGlass.inkTertiary.opacity(0.5))
                        .frame(height: 1)
                        .padding(.bottom, 18)

                    ScrollView {
                        Text(note.value)
                            .font(.system(size: 16))
                            .foregroundStyle(LiquidGlass.ink.opacity(0.85))
                            .lineSpacing(6)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(26)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .glassSurface(cornerRadius: 28)
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 40)
        }
        .navigationBarHidden(true)
        .hidesTabBarWhilePresented()
        .sheet(isPresented: $isEditing) {
            NavigationStack {
                EditNoteView(root.makeEditNoteViewModel(for: note))
            }
        }
        // .alert, no .confirmationDialog: mismo bug de iOS 26 documentado en
        // CategoriesListView (confirmationDialog puede perder el botón Cancelar).
        .alert(
            String(format: String(localized: "¿Eliminar \"%@\"?"), note.title),
            isPresented: $isConfirmingDelete
        ) {
            Button("Eliminar", role: .destructive) {
                onDelete()
                dismiss()
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Esta acción no se puede deshacer.")
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

            HStack(spacing: 10) {
                Button {
                    isEditing = true
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(LiquidGlass.systemBlue)
                        .glassCircle()
                }
                .accessibilityLabel(Text("Editar"))

                Button {
                    isConfirmingDelete = true
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(LiquidGlass.systemRed)
                        .frame(width: 40, height: 40)
                        .background(LiquidGlass.systemRed.opacity(0.14), in: Circle())
                }
                .accessibilityLabel(Text("Eliminar"))
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: Note.self, Category.self, configurations: .init(isStoredInMemoryOnly: true))
    NavigationStack {
        NoteDetailView(
            note: Note("Ideas para el rediseño", value: "Repasar el flujo de onboarding y unificar los estilos de botones antes de la demo del viernes.", category: Category("Trabajo", color: "BLUE"), createdAt: .now.addingTimeInterval(-7200)),
            root: CompositionRoot(modelContext: container.mainContext),
            onDelete: {}
        )
    }
    .environmentObject(TabBarVisibility())
}
