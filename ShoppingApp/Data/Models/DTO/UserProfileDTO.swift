//
//  UserProfileDTO.swift
//  ShoppingApp
//
//  Created by Tin Pham on 2/11/25.
//

import Foundation
import FirebaseFirestore

struct UserProfileDTO: Codable {
    @DocumentID var id: String?
    let uid: String
    let email: String
    let displayName: String?
    let photoURL: String?
    let createdAt: Timestamp
    let lastLoginAt: Timestamp
}
