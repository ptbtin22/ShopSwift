//
//  FirestoreUserRepository.swift
//  ShoppingApp
//
//  Created by Tin Pham on 2/11/25.
//

import Foundation
import FirebaseFirestore

final class FirestoreUserRepository: UserRepository {
    private let db = Firestore.firestore()
    
    func saveUser(_ user: User) async throws {
        let dto = UserProfileDTO(
            uid: user.uid,
            email: user.email,
            displayName: user.displayName,
            photoURL: user.photoURL?.absoluteString,
            createdAt: Timestamp(date: user.createdAt),
            lastLoginAt: Timestamp(date: Date())
        )
        
        try db.collection("users")
            .document(user.uid)
            .setData(from: dto, merge: true)
    }
    
    func getUser(uid: String) async throws -> User? {
        let snapshot = try await db.collection("users")
            .document(uid)
            .getDocument()
        
        guard let dto = try? snapshot.data(as: UserProfileDTO.self) else {
            return nil
        }
        
        return User(
            uid: dto.uid,
            email: dto.email,
            displayName: dto.displayName,
            photoURL: dto.photoURL.flatMap { URL(string: $0) },
            createdAt: dto.createdAt.dateValue()
        )
    }
    
    func deleteUser(uid: String) async throws {
        try await db.collection("users")
            .document(uid)
            .delete()
    }
}
