//
//  MockTransactionService.swift
//  Cora-ChallengeTests
//
//  Created by Yago Augusto Guedes Pereira on 28/06/24.
//

import Foundation
import Combine
@testable import Cora_Challenge

class MockTransactionService: TransactionServiceProtocol {
    var shouldReturnError = false

    func fetchTransactions() -> AnyPublisher<TransactionResponse, Error> {
        if shouldReturnError {
            return Fail(error: URLError(.badServerResponse)).eraseToAnyPublisher()
        } else {
            return Just(TransactionStubs.transactionResponse)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }

    func fetchTransactionDetails(id: String) -> AnyPublisher<TransactionDetailsResponse, Error> {
        if shouldReturnError {
            return Fail(error: URLError(.badServerResponse)).eraseToAnyPublisher()
        } else {
            return Just(TransactionStubs.transactionDetailsResponse)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
}
