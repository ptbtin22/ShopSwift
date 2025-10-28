//
//  MainViewModel.swift
//  ShoppingApp
//
//  Created by Tín Phạm on 12/10/25.
//

import Foundation
import RxSwift
import RxRelay

@MainActor
final class MainViewModel {
    
    // expose these
    struct ProductCellViewModel {
        let id: Int
        let title: String
        let subtitle: String
        let imageURL: URL?
    }

    // MARK: - State
    enum ViewState {
        case idle
        case loading
        case loadingMore  // state for pagination
        case loaded([ProductCellViewModel])
        case error(String)
    }

    // MARK: - Outputs (Reactive)
    let state: BehaviorRelay<ViewState> = BehaviorRelay(value: .idle)
    let hasMore: BehaviorRelay<Bool> = BehaviorRelay(value: true)  // Track if more products available
    
    // Keep track of all products and filtered products
    private var allProducts: [Product] = []
    private var filteredProducts: [Product] = []
    
    // Pagination state
    private var isLoadingMore = false
    private var currentSearchQuery: String = ""
    
    // MARK: - Spam Protection
    private var lastLoadTime: Date?
    private let minimumLoadInterval: TimeInterval = 0.5  // Prevent loads within 500ms

    // MARK: - Dependencies
    private let repository: ProductRepository

    init(repository: ProductRepository) {
        self.repository = repository
    }

    // MARK: - Inputs
    func load(offset: Int = 0, limit: Int = 20) {
        // 🛡️ Protection 1: Prevent concurrent loads
        guard !isLoadingMore else { return }
        
        // 🛡️ Protection 2: Debouncing - Prevent spam within 500ms
        if offset > 0, let lastLoad = lastLoadTime,
           Date().timeIntervalSince(lastLoad) < minimumLoadInterval {
            print("⏸️ Too soon since last load, ignoring pagination request")
            return
        }
        
        if offset == 0 {
            state.accept(.loading)
        } else {
            state.accept(.loadingMore)
            isLoadingMore = true
        }
        
        lastLoadTime = Date()
        
        Task {
            do {
                let list = try await repository.fetchProducts(offset: offset, limit: limit)
                
                if offset == 0 {
                    // Initial load or refresh
                    self.allProducts = list
                    self.filteredProducts = list
                } else {
                    // Load more - append to existing
                    self.allProducts.append(contentsOf: list)
                    
                    // If searching, filter new products too
                    if !currentSearchQuery.isEmpty {
                        let newFiltered = list.filter { product in
                            product.name.localizedCaseInsensitiveContains(currentSearchQuery) ||
                            product.category.localizedCaseInsensitiveContains(currentSearchQuery)
                        }
                        self.filteredProducts.append(contentsOf: newFiltered)
                    } else {
                        self.filteredProducts.append(contentsOf: list)
                    }
                }
                
                // Check if there are more items to load
                hasMore.accept(list.count >= limit)
                
                state.accept(.loaded(mapProductsToCellViewModels(filteredProducts)))
                isLoadingMore = false
            } catch {
                state.accept(.error(error.localizedDescription))
                isLoadingMore = false
            }
        }
    }
    
    func search(query: String) {
        currentSearchQuery = query
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            // Show all products when search is empty
            filteredProducts = allProducts
        } else {
            // Filter products by name or category (case-insensitive)
            filteredProducts = allProducts.filter { product in
                product.name.localizedCaseInsensitiveContains(trimmed) ||
                product.category.localizedCaseInsensitiveContains(trimmed)
            }
        }
        
        state.accept(.loaded(mapProductsToCellViewModels(filteredProducts)))
    }
    
    func didSelectProduct(at index: Int) -> Product? {
        guard index >= 0 && index < filteredProducts.count else { return nil }
        return filteredProducts[index]
    }
    
    // MARK: - Private Helpers
    private func mapProductsToCellViewModels(_ products: [Product]) -> [ProductCellViewModel] {
        products.map { product in
            ProductCellViewModel(
                id: product.id,
                title: product.name,
                subtitle: formatSubtitle(category: product.category, price: product.price),
                imageURL: product.imageURL
            )
        }
    }
    
    private func formatSubtitle(category: String, price: Double) -> String {
        "\(category) • $\(String(format: "%.2f", price))"
    }
}
