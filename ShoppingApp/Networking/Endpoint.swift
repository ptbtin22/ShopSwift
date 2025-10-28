//  Endpoint.swift
//  ShoppingApp
//
//  Created by Tín Phạm on 12/10/25.
//

import Foundation

public enum Endpoint  {
    case products
    case product(id: Int)
    
    var path: String {
        switch self {
        case .products: return "/products"  // Base URL already includes /api/v1
        case .product(let id): return "/products/\(id)"
        }
    }
}
