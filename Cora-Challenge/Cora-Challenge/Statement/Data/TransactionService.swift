//
//  TransactionService.swift
//  Cora-Challenge
//
//  Created by Yago Augusto Guedes Pereira on 26/06/24.
//

import Foundation
import Combine

// MARK: - Protocols
protocol TransactionServiceProtocol {
    func fetchTransactions() -> AnyPublisher<TransactionResponse, Error>
    func fetchTransactionDetails(id: String) -> AnyPublisher<TransactionDetailsResponse, Error>
}

// MARK: - TransactionService
final class TransactionService: TransactionServiceProtocol {
    
    // MARK: - Properties
    private let apiClient: ApiClientProtocol

    // MARK: - Initializer
    init(apiClient: ApiClientProtocol = ApiClient.shared) {
        self.apiClient = apiClient
    }

    // MARK: - Request Methods
    func fetchTransactions() -> AnyPublisher<TransactionResponse, Error> {
        apiClient.request(
            path: "/challenge/list",
            method: .get,
            responseType: TransactionResponse.self
        )
    }

    func fetchTransactionDetails(
        id: String
    ) -> AnyPublisher<TransactionDetailsResponse, Error> {
        apiClient.request(
            path: "/challenge/details/\(id)",
            method: .get,
            responseType: TransactionDetailsResponse.self
        )
    }
}
