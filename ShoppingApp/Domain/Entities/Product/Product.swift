//
//  Product.swift
//  ShoppingApp
//
//  Created by Tín Phạm on 12/10/25.
//

import Foundation

struct Product: Codable, Identifiable {
    let id: Int
    let name: String
    let category: String
    let price: Double
    let imageURL: URL?
    let stock: Int
    let rating: Double
    let description: String
}
