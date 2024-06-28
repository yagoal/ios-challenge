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
    func fetchTransactionDetails(id: String) -> AnyPublisher<TransactionDetailsResponse, Error>
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

    func fetchTransactionDetails(id: String) -> AnyPublisher<TransactionDetailsResponse, Error> {
        let path = "/challenge/details/\(id)"
        return apiClient.request(
            path: path,
            method: .get,
            responseType: TransactionDetailsResponse.self,
            body: nil,
            isLoginRequest: false,
            customHeaders: nil,
            isPrint: true
        )
    }
}
