//
//  URLSessionProductAPI.swift
//  ShoppingApp
//
//  Created by Tín Phạm on 12/10/25.
//

import Foundation

final class URLSessionProductAPI: ProductAPI {
    private let http: HTTPClient
    init(http: HTTPClient) { self.http = http }

    func getProducts(offset: Int?, limit: Int?) async throws -> [ProductDTO] {
        try await http.get(Endpoint.products.path, query: ["offset": offset, "limit": limit], headers: [:])
    }
    
    func getProduct(id: Int) async throws -> ProductDTO {
        try await http.get(Endpoint.product(id: id).path, query: nil, headers: [:])
    }
}
