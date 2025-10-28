//
//  CartViewModel.swift
//  ShoppingApp
//

import UIKit
import RxSwift
import RxRelay

@MainActor
final class CartViewModel {
    // MARK: - Dependencies
    private let store: CartStore
    private let disposeBag = DisposeBag()

    // MARK: - State
    let items: BehaviorRelay<[CartItem]>

    // MARK: - Init
    init(store: CartStore = UserDefaultsCartStore()) {
        self.store = store
        self.items = BehaviorRelay<[CartItem]>(value: store.items)

        // Keep VM in sync with the store using RxSwift
        store.itemsObservable
            .observe(on: MainScheduler.instance)
            .bind(to: items)
            .disposed(by: disposeBag)
    }
    
    public func getItems() -> [CartItem] {
        return items.value
    }

    // MARK: - Computed totals (cents-based)
    var totalItems: Int { items.value.reduce(0) { $0 + $1.quantity } }
    var subtotalCents: Int { items.value.reduce(0) { $0 + ($1.priceCents * $1.quantity) } }
    var subtotalFormatted: String { CurrencyFormatter.shared.string(fromCents: subtotalCents) }

    // MARK: - Intents / Mutations
    func addOrMerge(_ item: CartItem) {
        items.accept(store.upsert(item, mergeQuantity: true))
    }

    func setQuantity(for id: String, quantity: Int) {
        items.accept(store.setQuantity(for: id, quantity: quantity))
    }

    func increase(id: String, by delta: Int = 1, max: Int = .max) {
        items.accept(store.changeQuantity(for: id, delta: delta, min: 0, max: max))
    }

    func decrease(id: String, by delta: Int = 1) {
        items.accept(store.changeQuantity(for: id, delta: -abs(delta), min: 0, max: .max))
    }

    func remove(id: String) {
        items.accept(store.remove(id: id))
    }

    func clear() {
        items.accept(store.clear())
    }

    func item(withID id: String) -> CartItem? {
        store.item(withID: id)
    }
}

// MARK: - Currency helper (cents → string)
private final class CurrencyFormatter {
    static let shared = CurrencyFormatter()

    private let formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.locale = .current
        return f
    }()

    func string(fromCents cents: Int) -> String {
        let value = Decimal(cents) / 100
        return formatter.string(for: NSDecimalNumber(decimal: value)) ?? "\(value)"
    }
}
