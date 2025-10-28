//
//  Array+CartItem.swift
//  ShoppingApp
//
//  Created by Tín Phạm on 16/10/25.
//

import Foundation

extension Array where Element == CartItem {
    var totalItems: Int { reduce(0) { $0 + $1.quantity } }
    var totalCents: Int { reduce(0) { $0 + ($1.priceCents * $1.quantity) } }
}
