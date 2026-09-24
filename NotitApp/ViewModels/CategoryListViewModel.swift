//
//  CategoryListViewModel.swift
//  NotitApp
//
//  Created by Nicolas Valentini on 27/8/2026.
//
import Foundation

@MainActor
final class CategoryListViewModel: ObservableObject {
    
    @Published private(set) var state: ViewModelState<[Category]> = .idle
    
    private let useCase: CategoryUseCase
    
    init(useCase: CategoryUseCase) {
        self.useCase = useCase
    }
    
    func fetchCategories() async {
        state = .loading
        do {
            let categories = try await useCase.fetch()
            state = .loaded(categories)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    func deleteCategory(_ category: Category) async {
        state = .loading
        do {
            try await useCase.delete(category)
            let categories = try await useCase.fetch()
            state = .loaded(categories)
        } catch {
            state = .error(error.localizedDescription)
        }
        
    }
}
