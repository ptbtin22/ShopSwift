//
//  UserRepository.swift
//  ShoppingApp
//
//  Created by Tin Pham on 2/11/25.
//

import Foundation

protocol UserRepository {
    func saveUser(_ user: User) async throws
    func getUser(uid: String) async throws -> User?
    func deleteUser(uid: String) async throws
}
