//
//  CartStore.swift
//  ShoppingApp
//
//  Created by Tín Phạm on 16/10/25.
//

import Foundation
import RxSwift

public extension Notification.Name {
    static let cartDidChange = Notification.Name("cartDidChange")
}

// MARK: - Store Protocol

protocol CartStore {
    /// Current snapshot (cheap, returns cached)
    var items: [CartItem] { get }
    var itemsObservable: Observable<[CartItem]> { get }

    /// Replace or merge an item. Returns new snapshot.
    @discardableResult
    func upsert(_ item: CartItem, mergeQuantity: Bool) -> [CartItem]

    /// Set an exact quantity for a product id (0 removes). Returns new snapshot.
    @discardableResult
    func setQuantity(for id: String, quantity: Int) -> [CartItem]

    /// Convenience: increase/decrease by delta. Returns new snapshot.
    @discardableResult
    func changeQuantity(for id: String, delta: Int, min: Int, max: Int) -> [CartItem]

    /// Remove by id. Returns new snapshot.
    @discardableResult
    func remove(id: String) -> [CartItem]

    /// Clear all. Returns new snapshot (empty).
    @discardableResult
    func clear() -> [CartItem]

    /// Fetch single item
    func item(withID id: String) -> CartItem?
}
