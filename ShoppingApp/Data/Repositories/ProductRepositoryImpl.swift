//
//  ProductRepository.swift
//  ShoppingApp
//
//  Created by Tín Phạm on 12/10/25.
//

import Foundation

final class ProductRepositoryImpl : ProductRepository {
    private let api: ProductAPI
    init(api: ProductAPI) { self.api = api }
    
    func fetchProducts(offset: Int?, limit: Int?) async throws -> [Product] {
        // use multi-threading to call multiple times without crashing the app.
        let dtos = try await api.getProducts(offset: offset, limit: limit)
        return dtos.map { $0.toDomain() }
    }
}
