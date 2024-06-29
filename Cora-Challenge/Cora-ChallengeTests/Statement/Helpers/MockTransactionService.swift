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
            let transactions = [TransactionItem(id: "1", entry: .credit, amount: 100, date: "2022-01-01", description: "")]
            let response = TransactionResponse(results: transactions)
            return Just(response)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }

    func fetchTransactionDetails(id: String) -> AnyPublisher<TransactionDetailsResponse, Error> {
        if shouldReturnError {
            return Fail(error: URLError(.badServerResponse)).eraseToAnyPublisher()
        } else {
            let details = TransactionDetailsResponse(
                id: id,
                label: "Test",
                amount: 100,
                dateEvent: "2022-01-01T00:00:00Z",
                description: "Test Description",
                sender: AccountDetails(name: "Sender", documentType: "CPF", documentNumber: "12345678909", bankName: "Test Bank", agencyNumber: "0001", accountNumber: "123456-7"),
                recipient: AccountDetails(name: "Recipient", documentType: "CNPJ", documentNumber: "12345678000195", bankName: "Test Bank", agencyNumber: "0001", accountNumber: "123456-8")
            )
            return Just(details)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
}
