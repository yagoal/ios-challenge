//
//  StatementListViewModelTests.swift
//  Cora-ChallengeTests
//
//  Created by Yago Augusto Guedes Pereira on 28/06/24.
//

import Foundation
import Combine
import XCTest

@testable import Cora_Challenge

final class StatementListViewModelTests: XCTestCase {
    private var sut: StatementListViewModel!
    private var mockTransactionService: MockTransactionService!
    private var cancellables: Set<AnyCancellable>!

    let transactions = [
        TransactionResult(
            items: [
                TransactionItem(
                    id: "1",
                    description: "Test Transaction 1",
                    label: "Label 1",
                    entry: .credit,
                    amount: 100,
                    name: "Test 1",
                    dateEvent: "2022-01-02",
                    status: "completed"
                )
            ],
            date: "2022-01-02"
        ),
        TransactionResult(
            items: [
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
            ],
            date: "2022-01-01"
        )
    ]

    override func setUp() {
        super.setUp()
        mockTransactionService = MockTransactionService()
        sut = StatementListViewModel(transactionService: mockTransactionService)
        cancellables = []
    }

    override func tearDown() {
        sut = nil
        mockTransactionService = nil
        cancellables = nil
        super.tearDown()
    }
    
    func test_givenViewModel_whenFetchTransactionsSucceeds_thenStateIsSuccess() {
        // given
        let expectation = XCTestExpectation(description: "State should transition to .success")
        mockTransactionService.shouldReturnError = false

        // when
        sut.fetchTransactions()

        // then
        sut.$state
            .dropFirst()
            .sink { state in
                if case .success = state {
                    XCTAssertTrue(true)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func test_givenViewModel_whenFetchTransactionsFails_thenStateIsError() {
        // given
        let expectation = XCTestExpectation(description: "State should transition to .error")
        mockTransactionService.shouldReturnError = true

        // when
        sut.fetchTransactions()

        // then
        sut.$state
            .dropFirst()
            .sink { state in
                if case .error = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func test_givenInitialTransactions_whenFilterTransactionsByIncome_thenOnlyIncomeTransactionsAreShown() {
        // given
        sut.groupTransactionsByDate(transactions)
        
        // when
        sut.selectedFilter = .income
        sut.filterTransactions()
        
        // then
        if case let .success(filteredTransactions) = sut.state {
            XCTAssertEqual(filteredTransactions["2022-01-02"]?.count, 1)
            XCTAssertEqual(filteredTransactions["2022-01-02"]?.first?.entry, .credit)
        } else {
            XCTFail("State should be .success with filtered transactions")
        }
    }

    func test_givenInitialTransactions_whenFilterTransactionsByExpense_thenOnlyExpenseTransactionsAreShown() {
        // given
        sut.groupTransactionsByDate(transactions)
        
        // when
        sut.selectedFilter = .expense
        sut.filterTransactions()
        
        // then
        if case let .success(filteredTransactions) = sut.state {
            XCTAssertEqual(filteredTransactions["2022-01-01"]?.count, 1)
            XCTAssertEqual(filteredTransactions["2022-01-01"]?.first?.entry, .debit)
        } else {
            XCTFail("State should be .success with filtered transactions")
        }
    }

    func test_givenInitialTransactions_whenSortTransactionsByRecent_thenTransactionsAreSortedByDateDescending() {
        // given
        let shuffledTransactions = transactions.shuffled()
        sut.groupTransactionsByDate(shuffledTransactions)
        
        // when
        sut.sortOrder = .recent
        sut.reorderTransactions(sut.originalTransactions)
        
        // then
        if case let .success(sortedTransactions) = sut.state {
            let dates = sortedTransactions.keys.sorted(by: >)
            XCTAssertEqual(dates, ["2022-01-02", "2022-01-01"])
        } else {
            XCTFail("State should be .success with sorted transactions")
        }
    }

    func test_givenInitialTransactions_whenSortTransactionsByOldest_thenTransactionsAreSortedByDateAscending() {
        // given
        let shuffledTransactions = transactions.shuffled()
        sut.groupTransactionsByDate(shuffledTransactions)
        
        // when
        sut.sortOrder = .oldest
        sut.reorderTransactions(sut.originalTransactions)
        
        // then
        if case let .success(sortedTransactions) = sut.state {
            let dates = sortedTransactions.keys.sorted(by: <)
            XCTAssertEqual(dates, ["2022-01-01", "2022-01-02"])
        } else {
            XCTFail("State should be .success with sorted transactions")
        }
    }

    func test_formatSectionDate_forToday_returnsFormattedToday() {
        // Given today's date
        let today = Date()
        let dateFormatter = configureDateFormatter(withFormat: "yyyy-MM-dd")
        let dateString = dateFormatter.string(from: today)

        // When
        let formatted = sut.formatSectionDate(dateString)

        // Then
        let displayFormatter = configureDateFormatter(withFormat: "EEEE - dd 'de' MMMM")
        let expectedFormattedDate = "Hoje - \(displayFormatter.string(from: today))"
        XCTAssertEqual(formatted, expectedFormattedDate)
    }

    func test_formatSectionDate_forYesterday_returnsFormattedYesterday() {
        // Given yesterday's date
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let dateFormatter = configureDateFormatter(withFormat: "yyyy-MM-dd")
        let dateString = dateFormatter.string(from: yesterday)

        // When
        let formatted = sut.formatSectionDate(dateString)

        // Then
        let displayFormatter = configureDateFormatter(withFormat: "EEEE - dd 'de' MMMM")
        let expectedFormattedDate = "Ontem - \(displayFormatter.string(from: yesterday))"
        XCTAssertEqual(formatted, expectedFormattedDate)
    }

    func test_formatSectionDate_forRandomPastDate_returnsFormattedDate() {
        // Given a random past date
        let randomPastDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
        let dateFormatter = configureDateFormatter(withFormat: "yyyy-MM-dd")
        let dateString = dateFormatter.string(from: randomPastDate)

        // When
        let formatted = sut.formatSectionDate(dateString)

        // Then
        let displayFormatter = configureDateFormatter(withFormat: "EEEE - dd 'de' MMMM yyyy")
        let expectedFormattedDate = displayFormatter.string(from: randomPastDate)
        XCTAssertEqual(formatted, expectedFormattedDate)
    }

    private func configureDateFormatter(
        withFormat format: String,
        locale: String = "pt_BR",
        timeZone: TimeZone = TimeZone.current
    ) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: locale)
        formatter.timeZone = timeZone
        return formatter
    }
}
