 //
//  TransactionCellViewDataTests.swift
//  Cora-ChallengeTests
//
//  Created by Yago Augusto Guedes Pereira on 29/06/24.
//

import SwiftUI
import XCTest
@testable import Cora_Challenge

final class TransactionCellViewDataTests: XCTestCase {
    private var sut: TransactionCellViewData!
    private let dateFormatter = DateFormatter()

    override func setUp() {
        super.setUp()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_givenCreditTransaction_whenInitialized_thenCorrectlyFormatsProperties() {
        // Given
        let transaction = TransactionItem(
            id: "1",
            description: "Received payment",
            label: "Credit Transaction",
            entry: .credit,
            amount: 500,
            name: "John Doe",
            dateEvent: "2021-07-16T12:34:56+0000",
            status: "completed"
        )

        // When
        sut = TransactionCellViewData(item: transaction)

        // Then
        assertTransactionViewData(
            sut: sut,
            expectedId: "1",
            expectedColor: .primaryBlue,
            expectedIcon: Image(Icons.credit.rawValue),
            expectedAmount: formattedCurrency(amount: 500),
            expectedLabel: "Credit Transaction",
            expectedName: "John Doe",
            expectedHour: formattedHour(dateEvent: transaction.dateEvent)
        )
    }

    func test_givenDebitTransaction_whenInitialized_thenCorrectlyFormatsProperties() {
        // Given
        let transaction = TransactionItem(
            id: "2",
            description: "Paid rent",
            label: "Debit Transaction",
            entry: .debit,
            amount: 800,
            name: "Jane Doe",
            dateEvent: "2021-07-17T08:20:00+0000",
            status: "completed"
        )

        // When
        sut = TransactionCellViewData(item: transaction)

        // Then
        assertTransactionViewData(
            sut: sut,
            expectedId: "2",
            expectedColor: .black,
            expectedIcon: Image(Icons.debit.rawValue),
            expectedAmount: formattedCurrency(amount: 800),
            expectedLabel: "Debit Transaction",
            expectedName: "Jane Doe",
            expectedHour: formattedHour(dateEvent: transaction.dateEvent)
        )
    }

    func test_givenUnknownEntryTransaction_whenInitialized_thenCorrectlyFormatsProperties() {
        // Given
        let transaction = TransactionItem(
            id: "3",
            description: "Unknown transaction",
            label: "Unknown Type",
            entry: .unknown,
            amount: 30000,
            name: "Casey Smith",
            dateEvent: "2021-07-18T14:20:00+0000",
            status: "completed"
        )

        // When
        sut = TransactionCellViewData(item: transaction)

        // Then
        assertTransactionViewData(
            sut: sut,
            expectedId: "3",
            expectedColor: .gray,
            expectedIcon: Image(systemName: "questionmark.circle"),
            expectedAmount: formattedCurrency(amount: 30000),
            expectedLabel: "Unknown Type",
            expectedName: "Casey Smith",
            expectedHour: formattedHour(dateEvent: transaction.dateEvent)
        )
    }

    private func assertTransactionViewData(sut: TransactionCellViewData, expectedId: String, expectedColor: Color, expectedIcon: Image, expectedAmount: String, expectedLabel: String, expectedName: String, expectedHour: String) {
        XCTAssertEqual(sut.id, expectedId)
        XCTAssertEqual(sut.color, expectedColor)
        XCTAssertEqual(sut.icon, expectedIcon)
        XCTAssertEqual(sut.amount, expectedAmount)
        XCTAssertEqual(sut.label, expectedLabel)
        XCTAssertEqual(sut.name, expectedName)
        XCTAssertEqual(sut.hour, expectedHour)
    }

    private func formattedHour(dateEvent: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        inputFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        guard let date = inputFormatter.date(from: dateEvent) else {
            return "Invalid date"
        }

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "HH:mm"
        outputFormatter.timeZone = TimeZone.current

        return outputFormatter.string(from: date)
    }

    private func formattedCurrency(amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "BRL"
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: amount / 100)) ?? ""
    }
}
