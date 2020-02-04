//
//  APIService.swift
//  Levarti
//
//  Created by Lee, Ryan on 2/3/20.
//  Copyright © 2020 Lee, Ryan. All rights reserved.
//

import Foundation
struct APIService {

    static let `default` = APIService(baseURL: URL(string: "https://jsonplaceholder.typicode.com")!)
    let decoder = JSONDecoder()
    let baseURL: URL

    init(baseURL: URL) {
        self.baseURL = baseURL
    }

    enum APIError: Error {
        case noResponse
        case jsonDecodingError(error: Error)
        case networkError(error: Error)
    }

    enum Endpoint {
        case fetch
        case delete

        func path() -> String {
            switch self {
            case .fetch, .delete:
                return "/photos/"
            }
        }

        func httpMethod() -> String {
            switch self {
            case .fetch:
                return "GET"
            case .delete:
                return "DELETE"
            }
        }
    }
    func request<T: Codable>(endpoint: Endpoint, params: [String: String]?,completionHandler: @escaping (Result<T, APIError>) -> Void) {
        let queryURL = baseURL.appendingPathComponent(endpoint.path())
        var components = URLComponents(url: queryURL, resolvingAgainstBaseURL: true)!
        var queryItems = [URLQueryItem]()
        if let params = params {
            for (_, value) in params.enumerated() {
                queryItems.append(URLQueryItem(name: value.key, value: value.value))

            }
        }
        components.queryItems = queryItems
        var request = URLRequest(url: components.url!)
        request.httpMethod = endpoint.httpMethod()
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(.failure(.noResponse))
                }
                return
            }
            guard error == nil else {
                DispatchQueue.main.async {
                    completionHandler(.failure(.networkError(error: error!)))
                }
                return
            }
            do {
                let object = try self.decoder.decode(T.self, from: data)
                DispatchQueue.main.async {
                    completionHandler(.success(object))
                }
            } catch let error {
                DispatchQueue.main.async {
                    #if DEBUG
                    print("JSON Decoding a: \(error)")
                    #endif
                    completionHandler(.failure(.jsonDecodingError(error: error)))
                }
            }
        }
        task.resume()
    }
}
