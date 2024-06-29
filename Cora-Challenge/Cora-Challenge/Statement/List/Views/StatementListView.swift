//
//  StatementListView.swift
//  Cora-Challenge
//
//  Created by Yago Augusto Guedes Pereira on 26/06/24.
//

import SwiftUI

struct StatementListView: View {
    // MARK: - Properties
    @StateObject var viewModel = StatementListViewModel()
    @EnvironmentObject var coordinator: AppCoordinator

    // MARK: - Body
    var body: some View {
        VStack {
            headerView

            switch viewModel.state {
            case .loading:
                PlaceholderView()
            case .success(let transactions):
                if transactions.isEmpty {
                    EmptyStateView(message: "EmptyViewMessage")
                } else {
                    listView(transactions: transactions)
                }
            case .error(_):
                ErrorView(message: "ErrorViewMessage") {
                    viewModel.fetchTransactions()
                }
            default:
                EmptyView()
            }
        }
        .onAppear {
            viewModel.fetchTransactions()
        }
        .navigationBarTitle("Extrato", displayMode: .inline)
    }

    // MARK: - Header View
    private var headerView: some View {
        VStack {
            HStack(alignment: .top) {
                ForEach(FilterType.allCases, id: \.self) { filter in
                    Button(action: {
                        viewModel.selectedFilter = filter
                        viewModel.filterTransactions()
                    }) {
                        VStack {
                            Text(filter.rawValue)
                                .font(.avenirBodyBold(size: 14))
                                .foregroundColor(viewModel.selectedFilter == filter ? .primary : .neutralHigh)
                            if viewModel.selectedFilter == filter {
                                Rectangle()
                                    .fill(Color.primary)
                                    .frame(height: 2)
                            } else {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(height: 2)
                            }
                        }
                    }
                }

                Menu {
                    Button(action: {
                        viewModel.sortOrder = .recent
                        viewModel.filterTransactions()
                    }) {
                        Text("Mais Recentes")
                    }

                    Button(action: {
                        viewModel.sortOrder = .oldest
                        viewModel.filterTransactions()
                    }) {
                        Text("Mais Antigos")
                    }
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(.primary)
                        .padding(.leading, 8)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    // MARK: - List View
    private func listView(transactions: [String: [TransactionItem]]) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(sortedTransactionKeys(transactions: transactions), id: \.self) { date in
                    sectionView(date: date, transactions: transactions[date])
                }
            }
        }
    }

    // MARK: - Helper Methods
    private func sortedTransactionKeys(transactions: [String: [TransactionItem]]) -> [String] {
        transactions.keys.sorted(by: {
            viewModel.sortOrder == .recent ? $0 > $1 : $0 < $1
        })
    }

    private func sectionView(date: String, transactions: [TransactionItem]?) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(viewModel.formatSectionDate(date))
                    .font(.avenirBodyBold(size: 14))
                    .foregroundColor(.neutral)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .cornerRadius(8)
                
                Spacer()
            }
            .background(Color.gray.opacity(0.1))

            ForEach(transactions ?? []) { transaction in
                TransactionCell(viewData: .init(item: transaction))
                    .onTapGesture {
                        coordinator.showStatementDetails(
                            id: transaction.id,
                            transactionType: transaction.entry
                        )
                    }
            }
        }
    }
}

#Preview {
    StatementListView()
}
