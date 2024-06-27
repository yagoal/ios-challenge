//
//  AuthService.swift
//  Cora-Challenge
//
//  Created by Yago Augusto Guedes Pereira on 26/06/24.
//

import Foundation
import Combine

protocol AuthServiceProtocol {
    func authenticate(cpf: String, password: String) -> AnyPublisher<AuthResponse, Error>
}

class AuthService: AuthServiceProtocol {
    private let apiClient: ApiClientProtocol

    init(apiClient: ApiClientProtocol = ApiClient()) {
        self.apiClient = apiClient
    }

    func authenticate(cpf: String, password: String) -> AnyPublisher<AuthResponse, Error> {
        let path = "/challenge/auth"
        let headers = ["Content-Type": "application/json"]
        let body = ["cpf": cpf, "password": password]

        return apiClient.request(
            path: path,
            method: .post,
            responseType: AuthResponse.self,
            body: body,
            isLoginRequest: true,
            customHeaders: headers,
            isPrint: true
        )
    }
}
