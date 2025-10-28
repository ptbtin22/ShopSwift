//
//  ProductDetailsViewModel.swift
//  ShoppingApp
//
//  Created by Tín Phạm on 12/10/25.
//

import Foundation

@MainActor
final class ProductDetailsViewModel {
    
    private let favorites: FavoritesStore
    private let cartStore: CartStore
    
    private(set) var product: Product
    private(set) var isFavorite: Bool
    private(set) var quantity: Int
    
    var onUpdate: (() -> Void)?
    
    func increase() {
        guard quantity < stockCount else { return }
        quantity += 1
        onUpdate?()
    }

    func decrease() {
        let minAllowed = (stockCount == 0) ? 0 : 1
        guard quantity > minAllowed else { return }
        quantity -= 1
        onUpdate?()
    }

    func setQuantity(_ value: Int) {
        let minAllowed = (stockCount == 0) ? 0 : 1
        quantity = max(minAllowed, min(value, stockCount))
        onUpdate?()
    }
    
    func toggleFavorite() {
        isFavorite = favorites.toggle(product.id)
        onUpdate?()
    }
    
    func addToCart() {
        guard quantity > 0 else { return }
        cartStore.setQuantity(for: String(product.id), quantity: quantity)
    }
    
    init(product: Product, favorites: FavoritesStore, cartStore: CartStore) {
        self.product = product
        self.favorites = favorites
        self.cartStore = cartStore
        self.isFavorite = favorites.contains(product.id)
        self.quantity = product.stock == 0 ? 0 : 1
    }
    
    var titleText: String { product.name }
    var categoryText: String { product.category }
    var priceText: String { String(format: "$%.2f", product.price) }
    var imageURL: URL? { product.imageURL }
    var ratingText: String { String(format: "%.1f", product.rating) }
    var stockCount: Int { product.stock }
    var stockText: String { product.stock == 0 ? "Out of stock" : "\(product.stock) in stock" }
    var descriptionText: String { product.description }
}
