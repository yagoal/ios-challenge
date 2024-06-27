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
        isLoginRequest: Bool,
        customHeaders: [String: String]?,
        isPrint: Bool
    ) -> AnyPublisher<T, Error>
}

final class ApiClient: ApiClientProtocol {
    private let baseURLString = "https://api.challenge.stage.cora.com.br"
    private let apiKey = "d91dae118afc867467da958a6c159114"
    private var cancellables = Set<AnyCancellable>()
    private let keychainHelper = KeychainHelper.shared

    func request<T: Decodable>(
        path: String,
        method: HTTPMethod,
        responseType: T.Type,
        body: Encodable? = nil,
        isLoginRequest: Bool = false,
        customHeaders: [String: String]? = nil,
        isPrint: Bool = true
    ) -> AnyPublisher<T, Error> {
        guard let baseURL = URL(string: baseURLString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        let endpoint = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: endpoint)
        request.httpMethod = method.rawValue

        request.addValue(apiKey, forHTTPHeaderField: "apikey")

        if !isLoginRequest, let token = keychainHelper.getToken() {
            request.addValue(token, forHTTPHeaderField: "token")
        }

        customHeaders?.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }

        if let body = body, let bodyData = try? JSONEncoder().encode(body) {
            request.httpBody = bodyData
            if isPrint {
                print("Request Body JSON: \(prettyPrintedJSON(bodyData) ?? "Invalid JSON")")
            }
        }

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                if response.statusCode == 401 {
                    throw NetworkError.userAuthenticationRequired
                }
                return output.data
            }
            .catch { [weak self] error -> AnyPublisher<Data, Error> in
                guard let self = self, case NetworkError.userAuthenticationRequired = error else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
                return self.renewTokenAndRetry(request: request)
            }
            .tryMap { data in
                if let jsonString = self.prettyPrintedJSON(data), isPrint {
                    print("Response JSON: \(jsonString)")
                }
                return try JSONDecoder().decode(T.self, from: data)
            }
            .catch { error -> AnyPublisher<T, Error> in
                if let urlError = error as? URLError, urlError.code == .timedOut {
                    print("Erro: Timeout")
                    return Fail(error: NetworkError.timeoutError).eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    private func renewTokenAndRetry<T: Decodable>(request: URLRequest) -> AnyPublisher<T, Error> {
        guard let token = keychainHelper.getToken() else {
            return Fail(error: NetworkError.userAuthenticationRequired).eraseToAnyPublisher()
        }

        return renewToken(token: token)
            .flatMap { [weak self] authResponse -> AnyPublisher<T, Error> in
                self?.keychainHelper.saveToken(authResponse.token)
                var newRequest = request
                newRequest.setValue(authResponse.token, forHTTPHeaderField: "token")
                return URLSession.shared.dataTaskPublisher(for: newRequest)
                    .tryMap { output in
                        guard let response = output.response as? HTTPURLResponse else {
                            throw URLError(.badServerResponse)
                        }
                        if response.statusCode == 401 {
                            throw NetworkError.userAuthenticationRequired
                        }
                        return output.data
                    }
                    .tryMap { data in
                        if let jsonString = self?.prettyPrintedJSON(data) {
                            print("Response JSON after token renewal: \(jsonString)")
                        }
                        return try JSONDecoder().decode(T.self, from: data)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func renewToken(token: String) -> AnyPublisher<AuthResponse, Error> {
        let path = "/challenge/auth"
        let headers = ["Content-Type": "application/json"]
        let body = ["token": token]

        return request(
            path: path,
            method: .post,
            responseType: AuthResponse.self,
            body: body,
            isLoginRequest: true,
            customHeaders: headers,
            isPrint: true
        )
    }

    private func prettyPrintedJSON(_ data: Data) -> String? {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
              let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
}
