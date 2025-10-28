//
//  ProductDTO.swift
//  ShoppingApp
//
//  Created by Tín Phạm on 12/10/25.
//

import Foundation

// MARK: - Category DTO (nested in API response)
struct CategoryDTO: Codable {
    let id: Int
    let name: String
    let image: String
    let slug: String
}

// MARK: - Product DTO (matches API response from escuelajs.co)
struct ProductDTO: Codable {
    let id: Int
    let title: String
    let slug: String
    let price: Int  // API returns integer (e.g., 687)
    let description: String
    let category: CategoryDTO
    let images: [String]  // Array of image URL strings
    
    // Convert DTO → Domain Entity
    func toDomain() -> Product {
        Product(
            id: id,
            name: title,
            category: category.name,  // Extract category name from nested object
            price: Double(price),     // Convert Int → Double
            imageURL: URL(string: images.first ?? ""), // Use first image
            stock: 10,                 // API doesn't provide stock, default to 0
            rating: 0.0,              // API doesn't provide rating, default to 0.0
            description: description
        )
    }
}
