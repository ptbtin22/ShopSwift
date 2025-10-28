//
//  UserDefaultsCartStore.swift
//  ShoppingApp
//
//  Created by Tín Phạm on 16/10/25.
//

import Foundation
import RxSwift
import RxRelay

final class UserDefaultsCartStore: CartStore {

    // MARK: - Private
    private let key = "cart_v1"
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // Serial queue to make mutations atomic
    private let queue = DispatchQueue(label: "com.shopee.cart.store")

    // In-memory cache + reactive relay
    private var _items: [CartItem]
    private let relay: BehaviorRelay<[CartItem]>

    // MARK: - Public surface
    var items: [CartItem] { relay.value }
    var itemsObservable: Observable<[CartItem]> { relay.asObservable() }

    // MARK: - Init
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if
            let data = defaults.data(forKey: key),
            let decoded = try? decoder.decode([CartItem].self, from: data)
        {
            self._items = decoded
        } else {
            self._items = []
        }
        self.relay = BehaviorRelay<[CartItem]>(value: _items)
    }

    // MARK: - CartStore ops

    @discardableResult
    func upsert(_ newItem: CartItem, mergeQuantity: Bool) -> [CartItem] {
        queue.sync {
            var map = Dictionary(uniqueKeysWithValues: _items.map { ($0.id, $0) })
            if var existing = map[newItem.id], mergeQuantity {
                existing.quantity = max(0, existing.quantity + newItem.quantity)
                map[newItem.id] = existing
            } else {
                map[newItem.id] = newItem
            }
            _items = Array(map.values).sorted { $0.title < $1.title }
            persistAndNotify()
            return _items
        }
    }

    @discardableResult
    func setQuantity(for id: String, quantity: Int) -> [CartItem] {
        queue.sync {
            if let idx = _items.firstIndex(where: { $0.id == id }) {
                if quantity <= 0 {
                    _items.remove(at: idx)
                } else {
                    _items[idx].quantity = quantity
                }
                persistAndNotify()
            }
            return _items
        }
    }

    @discardableResult
    func changeQuantity(for id: String, delta: Int, min: Int = 0, max: Int = .max) -> [CartItem] {
        queue.sync {
            if let idx = _items.firstIndex(where: { $0.id == id }) {
                var qty = _items[idx].quantity + delta
                qty = Swift.max(min, Swift.min(max, qty))
                if qty <= 0 {
                    _items.remove(at: idx)
                } else {
                    _items[idx].quantity = qty
                }
                persistAndNotify()
            }
            return _items
        }
    }

    @discardableResult
    func remove(id: String) -> [CartItem] {
        queue.sync {
            _items.removeAll { $0.id == id }
            persistAndNotify()
            return _items
        }
    }

    @discardableResult
    func clear() -> [CartItem] {
        queue.sync {
            _items.removeAll()
            persistAndNotify()
            return _items
        }
    }

    func item(withID id: String) -> CartItem? {
        queue.sync { _items.first(where: { $0.id == id }) }
    }

    // MARK: - Persistence & notifications

    private func persistAndNotify() {
        if let data = try? encoder.encode(_items) {
            defaults.set(data, forKey: key)
        }
        // Push to RxSwift subscribers
        relay.accept(_items)
        // Post legacy notification (your UI badge observer uses this)
        NotificationCenter.default.post(
            name: .cartDidChange,
            object: self,
            userInfo: ["items": _items]
        )
    }
}
