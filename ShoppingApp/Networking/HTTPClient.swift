//
//  ShoppingApp
//
//  Created by Tín Phạm on 12/10/25.
//

public protocol HTTPClient {
    func get<T: Decodable>(
        _ path: String,
        query: [String: CustomStringConvertible?]?,
        headers: [String: String]
    ) async throws -> T
}
