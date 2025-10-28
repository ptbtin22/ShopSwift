//
//  FavoritesStore.swift
//  ShoppingApp
//
//  Created by Tín Phạm on 13/10/25.
//

import Foundation

final class UserDefaultsFavoritesStore: FavoritesStore {
    private let key = "favorites.productIDs"
    private let defaults: UserDefaults
    
    init(defaults: UserDefaults = .standard) { self.defaults = defaults }
    
    func all() -> Set<Int> { Set(defaults.array(forKey: key) as? [Int] ?? []) }
    
    func contains(_ id: Int) -> Bool { all().contains(id) }
    
    @discardableResult
    func toggle(_ id: Int) -> Bool {
        var set = all()
        let newState: Bool
        
        if set.contains(id) {
            set.remove(id)
            newState = false
        } else {
            set.insert(id)
            newState = true
        }
        
        defaults.set(Array(set), forKey: key)
        
        return newState
    }
}
