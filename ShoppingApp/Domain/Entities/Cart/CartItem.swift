//
//  CartItem.swift
//  ShoppingApp
//
//  Created by Tín Phạm on 12/10/25.
//

import Foundation

public struct CartItem: Codable, Hashable {
    public let id: String                 // your product id / SKU
    public var title: String
    public var priceCents: Int            // store money in cents to avoid Double issues
    public var imageURL: URL?
    public var quantity: Int

    public init(id: String,
                title: String,
                priceCents: Int,
                imageURL: URL? = nil,
                quantity: Int) {
        self.id = id
        self.title = title
        self.priceCents = priceCents
        self.imageURL = imageURL
        self.quantity = quantity
    }
}
