//
//  ProductRepository.swift
//  ShoppingApp
//
//  Created by Tín Phạm on 12/10/25.
//

import Foundation

protocol ProductRepository {
    func fetchProducts(offset: Int?, limit: Int?) async throws -> [Product]
}
