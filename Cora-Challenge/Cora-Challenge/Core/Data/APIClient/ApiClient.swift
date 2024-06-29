//
//  ApiClient.swift
//  Cora-Challenge
//
//  Created by Yago Augusto Guedes Pereira on 26/06/24.
//

import Foundation
import Combine

enum NetworkError: Error {
    case timeoutError
    case userAuthenticationRequired
}

protocol ApiClientProtocol {
    func request<T: Decodable>(
        path: String,
        method: HTTPMethod,
        responseType: T.Type,
        body: Encodable?,
        customHeaders: [String: String]?,
        isLoginRequest: Bool,
        isPrint: Bool
    ) -> AnyPublisher<T, Error>
    
    func request<T: Decodable>(
        path: String,
        method: HTTPMethod,
        responseType: T.Type
    ) -> AnyPublisher<T, Error>
    
    func request<T: Decodable>(
        path: String,
        method: HTTPMethod,
        responseType: T.Type,
        body: Encodable?,
        isLoginRequest: Bool
    ) -> AnyPublisher<T, Error>
}

final class ApiClient: ApiClientProtocol {
    // MARK: - Properties
    static let shared = ApiClient()
    private let baseURLString = "https://api.challenge.stage.cora.com.br"
    private let apiKey = "d91dae118afc867467da958a6c159114"
    private var cancellables = Set<AnyCancellable>()
    private let keychainHelper = KeychainHelper.shared
    var didRefreshToken: Double?

    // MARK: - Public Methods
    /// Makes a network request and returns a publisher with the response.
    /// - Parameters:
    ///   - path: The endpoint path.
    ///   - method: The HTTP method to use.
    ///   - responseType: The expected response type.
    ///   - body: The request body.
    ///   - customHeaders: Any custom headers to add to the request.
    ///   - isLoginRequest: Whether this is a login request.
    ///   - isPrint: Whether to print the request and response JSON.
    /// - Returns: A publisher emitting the decoded response or an error.
    func request<T: Decodable>(
        path: String,
        method: HTTPMethod,
        responseType: T.Type,
        body: Encodable? = nil,
        customHeaders: [String: String]? = nil,
        isLoginRequest: Bool = false,
        isPrint: Bool = true
    ) -> AnyPublisher<T, Error> {
        guard let baseURL = URL(string: baseURLString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        let endpoint = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: endpoint)
        request.httpMethod = method.rawValue
        
        request.addValue(apiKey, forHTTPHeaderField: "apikey")
        
        if isLoginRequest {
            didRefreshToken = Date().timeIntervalSince1970
        }
        
        if !isLoginRequest, let token = keychainHelper.getToken() {
            request.addValue(token, forHTTPHeaderField: "token")
        }

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        customHeaders?.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        if let body = body, let bodyData = try? JSONEncoder().encode(body) {
            request.httpBody = bodyData
            if isPrint {
                print("Request Body JSON: \(prettyPrintedJSON(bodyData) ?? "Invalid JSON")")
            }
        }
        
        return performRequest(request, responseType: responseType, isPrint: isPrint)
            .catch { [weak self] error -> AnyPublisher<T, Error> in
                guard let self, case NetworkError.userAuthenticationRequired = error else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
                return renewTokenAndRetry(request: request, responseType: responseType)
            }
            .eraseToAnyPublisher()
    }

    /// Makes a network request with only the required parameters and returns a publisher with the response.
    /// - Parameters:
    ///   - path: The endpoint path.
    ///   - method: The HTTP method to use.
    ///   - responseType: The expected response type.
    /// - Returns: A publisher emitting the decoded response or an error.
    func request<T: Decodable>(
        path: String,
        method: HTTPMethod,
        responseType: T.Type
    ) -> AnyPublisher<T, Error> {
        return request(
            path: path,
            method: method,
            responseType: responseType,
            body: nil,
            customHeaders: nil,
            isLoginRequest: false,
            isPrint: true
        )
    }

    /// Makes a network request with required parameters and optional body and login request flag, and returns a publisher with the response.
    /// - Parameters:
    ///   - path: The endpoint path.
    ///   - method: The HTTP method to use.
    ///   - responseType: The expected response type.
    ///   - body: The request body.
    ///   - isLoginRequest: Whether this is a login request.
    /// - Returns: A publisher emitting the decoded response or an error.
    func request<T: Decodable>(
        path: String,
        method: HTTPMethod,
        responseType: T.Type,
        body: Encodable?,
        isLoginRequest: Bool
    ) -> AnyPublisher<T, Error> {
        return request(
            path: path,
            method: method,
            responseType: responseType,
            body: body,
            customHeaders: nil,
            isLoginRequest: isLoginRequest,
            isPrint: true
        )
    }

    // MARK: - Request Handling
    private func performRequest<T: Decodable>(
        _ request: URLRequest,
        responseType: T.Type,
        isPrint: Bool
    ) -> AnyPublisher<T, Error> {
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { [weak self] output in
                guard let self = self, let response = output.response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }

                let timestampNow: Double = Date().timeIntervalSince1970
                var mustRenewToken = false
                
                if let didRefreshToken {
                    mustRenewToken = (timestampNow - didRefreshToken) > 60
                }

                if response.statusCode == 401 || mustRenewToken {
                    throw NetworkError.userAuthenticationRequired
                }
                return output.data
            }
            .tryMap { data in
                if let jsonString = self.prettyPrintedJSON(data), isPrint {
                    print("Response JSON: \(jsonString)")
                }
                return data
            }
            .flatMap { data -> AnyPublisher<T, Error> in
                do {
                    let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                    return Just(decodedResponse)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                } catch {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Token Renewal
    /// Renews the token and retries the request in case of token expiration.
    /// - Parameter request: The original request that needs to be retried.
    /// - Returns: A publisher emitting the decoded response or an error.
    private func renewTokenAndRetry<T: Decodable>(
        request: URLRequest,
        responseType: T.Type
    ) -> AnyPublisher<T, Error> {
        guard let token = keychainHelper.getToken() else {
            return Fail(error: NetworkError.userAuthenticationRequired).eraseToAnyPublisher()
        }

        return renewToken(token: token)
            .flatMap { [weak self] authResponse -> AnyPublisher<T, Error> in
                self?.keychainHelper.saveToken(authResponse.token)
                var newRequest = request
                newRequest.setValue(authResponse.token, forHTTPHeaderField: "token")
                return self?.performRequest(newRequest, responseType: T.self, isPrint: true)
                    .eraseToAnyPublisher() ?? Fail(error: NetworkError.userAuthenticationRequired).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    /// Sends a request to renew the authentication token.
    /// - Parameter token: The expired token.
    /// - Returns: A publisher emitting the new authentication response or an error.
    private func renewToken(token: String) -> AnyPublisher<AuthResponse, Error> {
        let path = "/challenge/auth"
        let body = ["token": token]

        return request(
            path: path,
            method: .post,
            responseType: AuthResponse.self,
            body: body,
            customHeaders: nil,
            isLoginRequest: true,
            isPrint: true
        )
    }

    // MARK: - JSON Utilities
    /// Converts Data to a pretty-printed JSON string for debugging.
    /// - Parameter data: The JSON data.
    /// - Returns: A pretty-printed JSON string or nil if conversion fails.
    private func prettyPrintedJSON(_ data: Data) -> String? {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
              let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
}
