//
//  TransactionDetailsViewModel.swift
//  Cora-Challenge
//
//  Created by Yago Augusto Guedes Pereira on 27/06/24.
//

import Foundation
import Combine

enum DetailViewState: Equatable {
    case initial
    case loading
    case success(TransactionDetailsResponse)
    case error(String)
}

final class TransactionDetailsViewModel: ObservableObject {
    // MARK: - Properties
    @Published var state: DetailViewState = .initial

    private let transactionService: TransactionServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initializer
    init(transactionService: TransactionServiceProtocol = TransactionService()) {
        self.transactionService = transactionService
    }

    // MARK: - Fetch Details Methods
    func fetchTransactionDetails(id: String) {
        state = .loading
        transactionService.fetchTransactionDetails(id: id)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.state = .error(error.localizedDescription)
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] details in
                self?.state = .success(details)
            })
            .store(in: &cancellables)
    }

    // MARK: - Date Formatting Methods
    func formatDate(_ date: String) -> String {
        let isoDateFormatter = DateFormatter()
        isoDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        isoDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        isoDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        guard let dateObj = isoDateFormatter.date(from: date) else { return date }

        let displayFormatter = DateFormatter()
        displayFormatter.locale = Locale(identifier: "pt_BR")

        let calendar = Calendar.current
        if calendar.isDateInToday(dateObj) {
            displayFormatter.dateFormat = "'Hoje - 'dd/MM/yyyy"
            return displayFormatter.string(from: dateObj)
        } else if calendar.isDateInYesterday(dateObj) {
            displayFormatter.dateFormat = "'Ontem - 'dd/MM/yyyy"
            return displayFormatter.string(from: dateObj)
        } else {
            displayFormatter.dateFormat = "dd/MM/yyyy"
            return displayFormatter.string(from: dateObj)
        }
    }

    // MARK: - Document Formatting Methods
    func formattedDocumentNumber(_ documentNumber: String) -> String {
        if documentNumber.isCPF {
            return formatCPF(documentNumber)
        } else if documentNumber.isCNPJ {
            return formatCNPJ(documentNumber)
        }
        return documentNumber
    }

    private func formatCPF(_ number: String) -> String {
        guard number.count == 11 else { return number }
        let first = number.index(number.startIndex, offsetBy: 3)
        let second = number.index(first, offsetBy: 3)
        let third = number.index(second, offsetBy: 3)
        return "\(number[..<first]).\(number[first..<second]).\(number[second..<third])-\(number[third...])"
    }

    private func formatCNPJ(_ number: String) -> String {
        guard number.count == 14 else { return number }
        let first = number.index(number.startIndex, offsetBy: 2)
        let second = number.index(first, offsetBy: 3)
        let third = number.index(second, offsetBy: 3)
        let fourth = number.index(third, offsetBy: 4)
        return "\(number[..<first]).\(number[first..<second]).\(number[second..<third])/\(number[third..<fourth])-\(number[fourth...])"
    }
}
