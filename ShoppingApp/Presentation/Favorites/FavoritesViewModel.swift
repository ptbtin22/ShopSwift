//
//  FavoritesViewModel.swift
//  ShoppingApp
//
//  Created by Tín Phạm on 16/10/25.
//

import UIKit
import RxSwift
import RxRelay

@MainActor
final class FavoritesViewModel {
    
    // MARK: - Cell ViewModel
    struct FavoritesCellViewModel {
        let id: Int
        let title: String
        let description: String
        let isLoading: Bool
        
        init(id: Int, title: String = "Loading...", description: String = "", isLoading: Bool = true) {
            self.id = id
            self.title = title
            self.description = description
            self.isLoading = isLoading
        }
        
        init(product: Product) {
            self.id = product.id
            self.title = product.name
            self.description = product.description
            self.isLoading = false
        }
    }
    
    // MARK: - State
    enum ViewState {
        case idle
        case loading
        case loaded([FavoritesCellViewModel])
        case empty
        case error(String)
    }
    
    // MARK: - Outputs (Observable)
    let state: BehaviorRelay<ViewState> = BehaviorRelay(value: .idle)
    
    // MARK: - Private
    private let api: ProductAPI
    private let store: FavoritesStore
    private var products: [Product] = []
    private var loadTask: Task<Void, Never>?
    
    // MARK: - Spam Protection
    private var isLoading = false
    private var lastLoadTime: Date?
    private let minimumLoadInterval: TimeInterval = 1.0  // Prevent loads within 1 second
    
    // MARK: - Init
    init(api: ProductAPI, store: FavoritesStore) {
        self.api = api
        self.store = store
    }
    
    // MARK: - Inputs
    func load() {
        // 🛡️ Protection 1: Prevent concurrent loads
        guard !isLoading else {
            print("⏸️ Already loading, ignoring request")
            return
        }
        
        // 🛡️ Protection 2: Debouncing - Prevent spam within 1 second
        if let lastLoad = lastLoadTime,
           Date().timeIntervalSince(lastLoad) < minimumLoadInterval {
            print("⏸️ Too soon since last load, ignoring request")
            return
        }
        
        // Cancel any in-flight load task
        loadTask?.cancel()
        
        let favoriteIDs = store.all()
        
        // Handle empty state
        if favoriteIDs.isEmpty {
            state.accept(.empty)
            return
        }
        
        // Mark as loading
        isLoading = true
        lastLoadTime = Date()
        
        // Show loading placeholders
        let placeholders = favoriteIDs.map { id in
            FavoritesCellViewModel(id: id)
        }
        state.accept(.loaded(placeholders))
        
        // Fetch products concurrently
        loadTask = Task { [weak self] in
            guard let self else { return }
            
            // 🛡️ Protection 3: Explicit background execution
            var loadedProducts: [Int: Product] = [:]
            
            await withTaskGroup(of: (id: Int, result: Result<Product, Error>).self) { group in
                for id in favoriteIDs {
                    group.addTask { [weak self] in
                        guard let self else {
                            return (id, .failure(CancellationError()))
                        }
                        
                        // 🛡️ Protection 4: Check for cancellation
                        if Task.isCancelled {
                            return (id, .failure(CancellationError()))
                        }
                        
                        do {
                            let dto = try await self.api.getProduct(id: id)
                            return (id, .success(dto.toDomain()))
                        } catch {
                            return (id, .failure(error))
                        }
                    }
                }
                
                for await (id, result) in group {
                    // 🛡️ Protection 5: Check for cancellation in loop
                    if Task.isCancelled {
                        break
                    }
                    
                    if case .success(let product) = result {
                        loadedProducts[id] = product
                    }
                }
            }
            
            // 🛡️ Protection 6: Don't update if cancelled
            guard !Task.isCancelled else {
                await MainActor.run {
                    self.isLoading = false
                }
                return
            }
            
            // Update state with loaded products
            self.products = Array(loadedProducts.values)
            
            let cellViewModels = favoriteIDs.compactMap { id -> FavoritesCellViewModel? in
                guard let product = loadedProducts[id] else {
                    return FavoritesCellViewModel(id: id, title: "Failed to load", description: "Product #\(id)", isLoading: false)
                }
                return FavoritesCellViewModel(product: product)
            }
            
            state.accept(.loaded(cellViewModels))
            isLoading = false  // Reset loading flag
        }
    }
    
    func didSelectProduct(at index: Int) -> Product? {
        guard index >= 0 && index < products.count else { return nil }
        return products[index]
    }
    
    func refresh() {
        load()
    }
}
