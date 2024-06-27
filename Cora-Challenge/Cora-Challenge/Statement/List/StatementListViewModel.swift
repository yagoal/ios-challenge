//
//  StatementListViewModel.swift
//  Cora-Challenge
//
//  Created by Yago Augusto Guedes Pereira on 26/06/24.
//

import Foundation
import Combine

import Foundation
import Combine

enum ViewState {
    case initial
    case loading
    case success([String: [TransactionItem]])
    case error(String)
}

final class StatementViewModel: ObservableObject {
    @Published var state: ViewState = .initial
    @Published var selectedFilter: FilterType = .all
    @Published var sortOrder: SortOrder = .recent

    private let transactionService: TransactionServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private var originalTransactions = [String: [TransactionItem]]()

    init(transactionService: TransactionServiceProtocol = TransactionService()) {
        self.transactionService = transactionService
    }

    func fetchTransactions() {
        state = .loading

        transactionService.fetchTransactions()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.state = .error(error.localizedDescription)
                }
            }, receiveValue: { [weak self] response in
                self?.groupTransactionsByDate(response.results)
            })
            .store(in: &cancellables)
    }

    private func groupTransactionsByDate(_ results: [TransactionResult]) {
        var groupedTransactions = [String: [TransactionItem]]()

        for result in results {
            groupedTransactions[result.date, default: []] += result.items
        }

        originalTransactions = groupedTransactions
        filterTransactions()
    }

    func filterTransactions() {
        var filteredTransactions = [String: [TransactionItem]]()
        
        for (date, items) in originalTransactions {
            let filteredItems: [TransactionItem]
            switch selectedFilter {
            case .all:
                filteredItems = items
            case .income:
                filteredItems = items.filter { $0.entry == .credit }
            case .expense:
                filteredItems = items.filter { $0.entry == .debit }
            case .future:
                filteredItems = []
            }
            if !filteredItems.isEmpty {
                filteredTransactions[date] = filteredItems
            }
        }

        reorderTransactions(filteredTransactions)
    }

    func reorderTransactions(_ transactions: [String: [TransactionItem]]) {
        let sortedDates: [String]
        switch sortOrder {
        case .recent:
            sortedDates = transactions.keys.sorted(by: >)
        case .oldest:
            sortedDates = transactions.keys.sorted(by: <)
        }
        
        var orderedTransactions = [String: [TransactionItem]]()
        for date in sortedDates {
            orderedTransactions[date] = transactions[date]
        }
        
        state = .success(orderedTransactions)
    }

    func formatSectionDate(_ date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from: date) else { return date }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "EEEE - dd 'de' MMMM"
        
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Hoje - \(displayFormatter.string(from: date))"
        } else if calendar.isDateInYesterday(date) {
            return "Ontem - \(displayFormatter.string(from: date))"
        } else if calendar.component(.year, from: date) != calendar.component(.year, from: Date()) {
            displayFormatter.dateFormat = "EEEE - dd 'de' MMMM yyyy"
        }
        return displayFormatter.string(from: date)
    }
}
