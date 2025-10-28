//
//  EditCartItemViewModel.swift
//  ShoppingApp
//
//  Created by Tín Phạm on 14/10/25.
//

import Foundation

@MainActor
final class EditCartItemViewModel {
    private let originalItem: CartItem
    private(set) var quantity: Int

    var onSave: ((CartItem) -> Void)?

    init(item: CartItem) {
        self.originalItem = item
        self.quantity = item.quantity
    }

    func updateQuantity(_ newValue: Int) {
        quantity = newValue
    }

    func save() {
//        let updated = CartItem(
//            id: originalItem.id,
//            name: originalItem.name,
//            price: originalItem.price,
//            quantity: quantity
//        )
//        onSave?(updated)
    }

    var itemName: String { originalItem.title }
}
