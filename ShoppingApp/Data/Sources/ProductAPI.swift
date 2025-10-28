//
//  ProductAPI.swift
//  ShoppingApp
//
//  Created by Tín Phạm on 12/10/25.
//

protocol ProductAPI {
    func getProducts(offset: Int?, limit: Int?) async throws -> [ProductDTO]
    func getProduct(id: Int) async throws -> ProductDTO
}
