//
//  TransactionService.swift
//  Cora-Challenge
//
//  Created by Yago Augusto Guedes Pereira on 26/06/24.
//

import Foundation
import Combine

protocol TransactionServiceProtocol {
    func fetchTransactions() -> AnyPublisher<TransactionResponse, Error>
}

final class TransactionService: TransactionServiceProtocol {
    private let apiClient: ApiClientProtocol

    init(apiClient: ApiClientProtocol = ApiClient()) {
        self.apiClient = apiClient
    }

    func fetchTransactions() -> AnyPublisher<TransactionResponse, Error> {
        return apiClient.request(
            path: "/challenge/list",
            method: .get,
            responseType: TransactionResponse.self,
            body: nil,
            isLoginRequest: false,
            customHeaders: nil,
            isPrint: true
        )
    }
}
