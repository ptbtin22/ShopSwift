//
//  ShoppingApp
//
//  Created by Tín Phạm on 12/10/25.
//

import Foundation

public final class URLSessionHTTPClient: HTTPClient {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder

    public init(
        baseURL: URL,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
    }

        public func get<T: Decodable>(
        _ path: String,
        query: [String: CustomStringConvertible?]? = nil,
        headers: [String: String] = [:]
    ) async throws -> T {
        let url = try buildURL(path: path, query: query)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        do {
            let (data, response) = try await session.data(for: request)
            try validate(response: response, data: data)
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decodingFailed(underlying: error)
            }
        } catch {
            // If it's already an APIError, forward it; otherwise wrap
            if let apiError = error as? APIError { throw apiError }
            throw APIError.requestFailed(underlying: error)
        }
    }

    private func buildURL(
        path: String,
        query: [String: CustomStringConvertible?]?
    ) throws -> URL {
        // Support either "/foo" or "foo"
        var url = baseURL
        if path.hasPrefix("/") {
            url.appendPathComponent(String(path.dropFirst()))
        } else {
            url.appendPathComponent(path)
        }

        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL
        }

        if let query {
            components.queryItems = query.compactMap { key, value in
                guard let value else { return nil }
                return URLQueryItem(name: key, value: String(describing: value))
            }
        }

        guard let finalURL = components.url else { throw APIError.invalidURL }
        return finalURL
    }

    private func validate(response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else { return }
        guard (200..<300).contains(http.statusCode) else {
            throw APIError.badStatus(code: http.statusCode, data: data)
        }
    }
}
