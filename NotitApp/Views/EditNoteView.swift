//
//  EditNoteView.swift
//  NotitApp
//
import Foundation
import SwiftUI

struct EditNoteView: View {

    private enum Field {
        case title, body
    }

    // @StateObject — see AddNoteView for why @ObservedObject on an
    // inline-constructed view model is unsafe here.
    @StateObject private var viewModel: EditNoteViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isAddingCategory = false
    @FocusState private var focusedField: Field?

    init(_ viewModel: EditNoteViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    private static let backdrop: [GlassBackdrop.Blob] = [
        .init(color: LiquidGlass.systemBlue, size: 230, blur: 75, opacity: 0.30, corner: .topLeading, inset: CGPoint(x: 65, y: 45)),
        .init(color: LiquidGlass.systemOrange, size: 270, blur: 85, opacity: 0.22, corner: .topTrailing, inset: CGPoint(x: 65, y: 105)),
        .init(color: LiquidGlass.systemPurple, size: 230, blur: 75, opacity: 0.20, corner: .bottomTrailing, inset: CGPoint(x: 65, y: 45)),
    ]

    var body: some View {
        ZStack {
            GlassBackdrop(blobs: Self.backdrop)

            VStack(alignment: .leading, spacing: 0) {
                topBar
                    .padding(.bottom, 22)

                TextField("Título", text: $viewModel.title)
                    .font(.system(size: 19, weight: .bold))
                    .accessibilityLabel(Text("Título"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .glassSurface(cornerRadius: 18)
                    .padding(.bottom, 16)
                    .focused($focusedField, equals: .title)

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 13))
                        .foregroundStyle(LiquidGlass.systemRed)
                        .padding(.bottom, 8)
                }

                Text("CATEGORÍA")
                    .font(.system(size: 13, weight: .bold))
                    .tracking(0.5)
                    .foregroundStyle(LiquidGlass.inkSecondary)
                    .accessibilityAddTraits(.isHeader)
                    .padding(.bottom, 10)

                if viewModel.categories.isEmpty {
                    NoCategoriesPrompt { isAddingCategory = true }
                        .padding(.bottom, 18)
                } else {
                    FlowLayout(spacing: 8) {
                        ForEach(viewModel.categories) { category in
                            CategoryChip(
                                category: category,
                                isSelected: viewModel.selectedCategory == category
                            ) {
                                viewModel.selectedCategory = category
                            }
                        }
                    }
                    .padding(.bottom, 18)
                }

                ZStack(alignment: .topLeading) {
                    if viewModel.value.isEmpty {
                        Text("Escribí tu nota...")
                            .font(.system(size: 16))
                            .foregroundStyle(LiquidGlass.inkTertiary)
                            .padding(.top, 8)
                            .padding(.leading, 5)
                            .accessibilityHidden(true)
                    }
                    TextEditor(text: $viewModel.value)
                        .font(.system(size: 16))
                        .scrollContentBackground(.hidden)
                        .accessibilityLabel(Text("Nota"))
                        .accessibilityHint(viewModel.value.isEmpty ? Text("Escribí tu nota...") : Text(""))
                        .focused($focusedField, equals: .body)
                }
                .padding(16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .glassSurface(cornerRadius: 24)
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 40)
        }
        .navigationBarHidden(true)
        .contentShape(Rectangle())
        .onTapGesture { focusedField = nil }
        .task {
            await viewModel.loadCategories()
        }
        .onChange(of: viewModel.didSave) {
            if viewModel.didSave { dismiss() }
        }
        .sheet(isPresented: $isAddingCategory) {
            NavigationStack {
                AddCategoryView(viewModel.makeAddCategoryViewModel())
            }
        }
        .onChange(of: isAddingCategory) {
            if !isAddingCategory {
                Task { await viewModel.loadCategories() }
            }
        }
    }

    private var topBar: some View {
        HStack {
            Button("Cancelar") {
                focusedField = nil
                dismiss()
            }
                .font(.system(size: 16))
                .foregroundStyle(LiquidGlass.primary)

            Spacer()

            Text("Editar nota")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(LiquidGlass.ink)

            Spacer()

            Button("Guardar") {
                focusedField = nil
                Task { await viewModel.saveChanges() }
            }
            .buttonStyle(GradientPillButtonStyle(tint: LiquidGlass.primary))
            .disabled(!viewModel.canSave)
            .opacity(viewModel.canSave ? 1 : 0.4)
        }
    }
}

#Preview {
    let category = Category("Trabajo", color: "BLUE")
    let note = Note("Ideas para el rediseño", value: "Repasar el flujo de onboarding.", category: category, createdAt: .now)
    return NavigationStack {
        EditNoteView(EditNoteViewModel(note: note, noteUseCase: MockNoteUseCase(), categoryUseCase: MockCategoryUseCase()))
    }
}
