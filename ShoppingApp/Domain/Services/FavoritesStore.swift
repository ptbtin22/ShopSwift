//
//  FavoritesStore.swift
//  ShoppingApp
//
//  Created by Tín Phạm on 13/10/25.
//

import Foundation

protocol FavoritesStore {
    func all() -> Set<Int>
    func contains(_ id: Int) -> Bool
    @discardableResult func toggle(_ id: Int) -> Bool
}
