//
//  TransactionDetailsViewModelTests.swift
//  Cora-ChallengeTests
//
//  Created by Yago Augusto Guedes Pereira on 28/06/24.
//

import Combine
import XCTest
import PDFKit

@testable import Cora_Challenge

final class TransactionDetailsViewModelTests: XCTestCase {
    private var sut: TransactionDetailsViewModel!
    private var mockTransactionService: MockTransactionService!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockTransactionService = MockTransactionService()
        sut = TransactionDetailsViewModel(transactionService: mockTransactionService)
        cancellables = []
    }

    override func tearDown() {
        sut = nil
        mockTransactionService = nil
        cancellables = nil
        super.tearDown()
    }

    func test_whenViewModelIsInitialized_thenStateIsInitial() {
        // When
        let initialState = sut.state

        // Then
        XCTAssertEqual(initialState, .initial, "Initial state should be .initial")
    }

    func test_givenServiceReturnsSuccess_whenFetchTransactionDetails_thenStateIsSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "State should transition to .success")
        mockTransactionService.shouldReturnError = false
        let transactionID = "123"

        // When
        sut.fetchTransactionDetails(id: transactionID)

        // Then
        sut.$state
            .dropFirst()
            .sink { state in
                if case .success = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func test_givenServiceReturnsFailure_whenFetchTransactionDetails_thenStateIsError() {
        // Given
        let expectation = XCTestExpectation(description: "State should transition to .error")
        mockTransactionService.shouldReturnError = true
        let transactionID = "123"

        // When
        sut.fetchTransactionDetails(id: transactionID)

        // Then
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

    func test_givenValidDateFormat_whenFormatDateForToday_thenReturnsFormattedToday() {
        // Given
        let today = Date()
        let todayString = formattedDateString(from: today)

        // When
        let formattedDate = sut.formatDate(todayString)

        // Then
        XCTAssertEqual(formattedDate, "Hoje - \(DateFormatter.localizedString(from: today, dateStyle: .short, timeStyle: .none))")
    }

    func test_givenValidDateFormat_whenFormatDateForYesterday_thenReturnsFormattedYesterday() {
        // Given
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let yesterdayString = formattedDateString(from: yesterday)

        // When
        let formattedDate = sut.formatDate(yesterdayString)

        // Then
        XCTAssertEqual(formattedDate, "Ontem - \(DateFormatter.localizedString(from: yesterday, dateStyle: .short, timeStyle: .none))")
    }

    func test_givenRandomPastDate_whenFormatDate_thenReturnsFormattedDate() {
        // Given
        let randomPastDate = Calendar.current.date(byAdding: .year, value: -2, to: Date())!
        let pastDateString = formattedDateString(from: randomPastDate)

        // When
        let formattedDate = sut.formatDate(pastDateString)

        // Then
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "dd/MM/yyyy"
        displayFormatter.locale = Locale(identifier: "pt_BR")
        let expectedFormattedDate = displayFormatter.string(from: randomPastDate)
        
        XCTAssertEqual(formattedDate, expectedFormattedDate)
    }

    func test_givenValidCPF_whenFormatCPF_thenReturnsFormattedCPF() {
        // Given
        let validCPF = "08697229480"

        // When
        let formattedCPF = sut.formattedDocumentNumber(validCPF)

        // Then
        XCTAssertEqual(formattedCPF, "086.972.294-80")
    }

    func test_givenValidCNPJ_whenFormatCNPJ_thenReturnsFormattedCNPJ() {
        // Given
        let validCNPJ = "72952406000185"

        // When
        let formattedCNPJ = sut.formattedDocumentNumber(validCNPJ)

        // Then
        XCTAssertEqual(formattedCNPJ, "72.952.406/0001-85")
    }

    func test_givenTransactionDetails_whenGeneratePDF_thenReturnsNonNilDataWithCorrectAttributes() throws {
        // Given
        let details = TransactionStubs.transactionDetailsResponse

        // When
        let pdfData = sut.generatePDF(details: details)

        // Then
        let data = try XCTUnwrap(pdfData, "PDF data should not be nil")
        let document = try XCTUnwrap(PDFDocument(data: data), "Failed to create PDFDocument from data")
        let attributes = document.documentAttributes

        let expectedTitle = "Comprovante de Transferência"
        let expectedCreator = "Cora Bank"
        let expectedAuthor = "corabank.com.br"

        XCTAssertEqual(attributes?[PDFDocumentAttribute.titleAttribute] as? String, expectedTitle)
        XCTAssertEqual(attributes?[PDFDocumentAttribute.creatorAttribute] as? String, expectedCreator)
        XCTAssertEqual(attributes?[PDFDocumentAttribute.authorAttribute] as? String, expectedAuthor)
    }

    private func formattedDateString(from date: Date) -> String {
        let isoFormatter = DateFormatter()
        isoFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return isoFormatter.string(from: date)
    }
}
