//
//  TransactionStubs.swift
//  Cora-ChallengeTests
//
//  Created by Yago Augusto Guedes Pereira on 28/06/24.
//

import Foundation
@testable import Cora_Challenge

struct TransactionStubs {
    static let transactionItems: [TransactionItem] = [
        TransactionItem(
            id: "1",
            description: "Test Transaction 1",
            label: "Label 1",
            entry: .credit,
            amount: 100,
            name: "Test 1",
            dateEvent: "2022-01-01",
            status: "completed"
        ),
        TransactionItem(
            id: "2",
            description: "Test Transaction 2",
            label: "Label 2",
            entry: .debit,
            amount: 50,
            name: "Test 2",
            dateEvent: "2022-01-01",
            status: "completed"
        )
    ]

    static let transactionResults: [TransactionResult] = [
        TransactionResult(items: transactionItems, date: "2022-01-01")
    ]

    static let transactionResponse = TransactionResponse(results: transactionResults, itemsTotal: transactionItems.count)

    static let transactionDetailsResponse = TransactionDetailsResponse(
        id: "1",
        description: "Test Description",
        label: "Test",
        amount: 100,
        counterPartyName: "Counterparty",
        dateEvent: "2022-01-01T00:00:00Z",
        recipient: AccountDetails(
            bankName: "Test Bank",
            bankNumber: "123",
            documentNumber: "12345678000195",
            documentType: "CNPJ",
            accountNumberDigit: "8",
            agencyNumberDigit: "1",
            agencyNumber: "0001",
            name: "Recipient",
            accountNumber: "123456"
        ),
        sender: AccountDetails(
            bankName: "Test Bank",
            bankNumber: "123",
            documentNumber: "12345678909",
            documentType: "CPF",
            accountNumberDigit: "7",
            agencyNumberDigit: "1",
            agencyNumber: "0001",
            name: "Sender",
            accountNumber: "123456"
        ),
        status: "completed"
    )
}
