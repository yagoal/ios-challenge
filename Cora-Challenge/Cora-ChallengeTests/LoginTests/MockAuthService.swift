//
//  MockAuthService.swift
//  Cora-ChallengeTests
//
//  Created by Yago Augusto Guedes Pereira on 28/06/24.
//

import Combine
import XCTest

@testable import Cora_Challenge

class MockAuthService: AuthServiceProtocol {
    var shouldReturnError = false
    var authResponse: AuthResponse?

    func authenticate(cpf: String, password: String) -> AnyPublisher<AuthResponse, Error> {
        if shouldReturnError {
            return Fail(error: URLError(.badServerResponse)).eraseToAnyPublisher()
        } else {
            let response = authResponse ?? AuthResponse(token: "mockToken")
            return Just(response)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
}
