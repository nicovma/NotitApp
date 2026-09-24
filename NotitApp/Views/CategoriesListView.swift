//
//  CategoriesListView.swift
//  NotitApp
//
//  Created by Nicolas Valentini on 27/8/2026.
//
import Foundation
import SwiftUI
import SwiftData

struct CategoriesListView: View {

    @StateObject private var viewModel: CategoryListViewModel
    private let root: CompositionRoot
    @State private var path = NavigationPath()
    @State private var categoryPendingDeletion: Category?
    @State private var categoryPendingEdit: Category?
    @State private var isAddingCategory = false

    init(_ viewModel: CategoryListViewModel, root: CompositionRoot) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.root = root
    }

    private static let backdrop: [GlassBackdrop.Blob] = [
        .init(color: LiquidGlass.systemPurple, size: 230, blur: 75, opacity: 0.32, corner: .topLeading, inset: CGPoint(x: 65, y: 45)),
        .init(color: LiquidGlass.systemOrange, size: 270, blur: 85, opacity: 0.28, corner: .topTrailing, inset: CGPoint(x: 65, y: 105)),
        .init(color: LiquidGlass.systemGreen, size: 250, blur: 85, opacity: 0.25, corner: .bottomLeading, inset: CGPoint(x: 45, y: 305)),
        .init(color: LiquidGlass.systemBlue, size: 230, blur: 75, opacity: 0.25, corner: .bottomTrailing, inset: CGPoint(x: 65, y: 45)),
    ]

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                GlassBackdrop(blobs: Self.backdrop)

                switch viewModel.state {
                case .idle, .loading:
                    ProgressView()

                case .loaded(let categories):
                    VStack(spacing: 0) {
                        header
                        List {
                            ForEach(categories) { category in
                                CategoryRow(category: category)
                                    .contentShape(Rectangle())
                                    .onTapGesture { path.append(category) }
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                                    .swipeActions {
                                        // Sin `role: .destructive`: con ese role, iOS anima la fila
                                        // como si ya estuviera borrada apenas se toca el botón — antes
                                        // de que corra esta closure. Como acá todavía no borramos nada
                                        // (solo mostramos el diálogo de confirmación), esa animación
                                        // automática hace que la fila "desaparezca y vuelva a aparecer"
                                        // antes de que se vea el diálogo.
                                        Button("Eliminar") {
                                            categoryPendingDeletion = category
                                        }
                                        .tint(LiquidGlass.systemRed)

                                        Button("Editar") {
                                            categoryPendingEdit = category
                                        }
                                        .tint(LiquidGlass.systemBlue)
                                    }
                            }
                            Color.clear.frame(height: 90)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 60)
                    .navigationDestination(for: Category.self) { category in
                        CategoryNotesListView(
                            root.makeCategoryNotesViewModel(for: category),
                            path: $path,
                            root: root
                        )
                    }

                case .error(let message):
                    Text(message)
                }
            }
            .navigationBarHidden(true)
            .task { await viewModel.fetchCategories() }
            // .alert, no .confirmationDialog: en iOS 26, confirmationDialog puede
            // renderizarse como un popover "Liquid Glass" en vez de action sheet,
            // y en ese modo pierde el botón Cancelar (bug de Apple, sin fix de
            // nuestro lado — probado anclándolo a la fila y persiste). Un alert
            // sí/no es además la API más apropiada para esta confirmación binaria.
            .alert(
                categoryPendingDeletion.map { String(format: String(localized: "¿Eliminar \"%@\"?"), $0.name) } ?? "",
                isPresented: Binding(
                    get: { categoryPendingDeletion != nil },
                    set: { isPresented in if !isPresented { categoryPendingDeletion = nil } }
                )
            ) {
                Button("Eliminar", role: .destructive) {
                    if let category = categoryPendingDeletion {
                        Task { await viewModel.deleteCategory(category) }
                    }
                    categoryPendingDeletion = nil
                }
                Button("Cancelar", role: .cancel) {
                    categoryPendingDeletion = nil
                }
            } message: {
                Text("Esta acción no se puede deshacer: se van a eliminar también todas las notas de esta categoría.")
            }
            .sheet(isPresented: $isAddingCategory) {
                NavigationStack {
                    AddCategoryView(root.makeAddCategoryViewModel())
                }
            }
            .onChange(of: isAddingCategory) {
                // CategoriesListView vive todo el ciclo de vida de la app dentro
                // del TabView, así que su .task inicial no vuelve a correr al
                // volver de "Nueva categoría" — sin este refetch explícito, la
                // categoría se guarda pero la lista se queda con el estado viejo.
                if !isAddingCategory {
                    Task { await viewModel.fetchCategories() }
                }
            }
            .sheet(item: $categoryPendingEdit) { category in
                NavigationStack {
                    EditCategoryView(root.makeEditCategoryViewModel(for: category))
                }
            }
            .onChange(of: categoryPendingEdit) {
                if categoryPendingEdit == nil {
                    Task { await viewModel.fetchCategories() }
                }
            }
        }
    }

    private var header: some View {
        HStack {
            Text("Categorías")
                .font(.system(size: 34, weight: .heavy))
                .foregroundStyle(LiquidGlass.ink)
            Spacer()
            Button {
                isAddingCategory = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(LiquidGlass.primary)
                    .glassCircle()
            }
            .accessibilityLabel(Text("Nueva categoría"))
        }
        .padding(.bottom, 24)
    }

}

struct CategoryRow: View {
    let category: Category

    var body: some View {
        let color = CategoryColor(rawValue: category.color)?.swiftUIColor ?? .gray

        HStack(spacing: 14) {
            Circle()
                .fill(RadialGradient(colors: [color.opacity(0.55), color], center: .init(x: 0.3, y: 0.3), startRadius: 0, endRadius: 24))
                .frame(width: 42, height: 42)
                .shadow(color: color.opacity(0.4), radius: 8, x: 0, y: 3)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(category.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(LiquidGlass.ink)
                Text("\(category.notes.count) notas")
                    .font(.system(size: 13))
                    .foregroundStyle(LiquidGlass.inkSecondary)
            }

            Spacer()
        }
        .padding(14)
        .glassSurface(cornerRadius: 22, borderOpacity: 0.7)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    let container = try! ModelContainer(for: Note.self, Category.self, configurations: .init(isStoredInMemoryOnly: true))
    CategoriesListView(
        CategoryListViewModel(useCase: MockCategoryUseCase()),
        root: CompositionRoot(modelContext: container.mainContext)
    )
    .environmentObject(TabBarVisibility())
}
