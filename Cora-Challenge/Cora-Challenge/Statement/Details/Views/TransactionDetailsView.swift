//
//  TransactionDetailsView.swift
//  Cora-Challenge
//
//  Created by Yago Augusto Guedes Pereira on 27/06/24.
//

import SwiftUI

struct TransactionDetailsView: View {
    // MARK: - Properties
    @StateObject var viewModel = TransactionDetailsViewModel()
    let transactionId: String
    let transactionType: Entry
    let onTapShareShareReceipt: (_ item: [Any]) -> Void
    @State private var showShareSheet = false
    @State private var pdfData: Data?

    // MARK: - Body
    var body: some View {
        Group {
            switch viewModel.state {
            case .loading, .initial:
                TransactionDetailsPlaceholderView()
            case .success(let details):
                VStack(alignment: .leading) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            headerView(details)
                            valueSection(details)
                            dateSection(details)
                            partySection(title: "De", details: details.sender)
                            partySection(title: "Para", details: details.recipient)
                            descriptionSection(details)
                        }
                    }
                    Spacer()
                    shareButton(details)
                }
                .padding(24)
            case .error(_):
                ErrorView(message: LocalizedStringKey("ErrorViewMessage")) {
                    viewModel.fetchTransactionDetails(id: transactionId)
                }
            }
        }
        .onAppear {
            viewModel.fetchTransactionDetails(id: transactionId)
        }
        .navigationBarTitle("Detalhes da transferência", displayMode: .inline)
    }

    // MARK: - Sections Views
    private func headerView(_ details: TransactionDetailsResponse) -> some View {
        HStack {
            icon(for: transactionType)
            Text(details.label)
                .font(.avenirBodyBold(size: 16))
                .foregroundColor(.neutralHigh)
        }
    }

    private func valueSection(_ details: TransactionDetailsResponse) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Valor")
                .font(.avenirBodyRegular(size: 14))
                .foregroundColor(.neutral)
            Text(details.amount.formattedCurrencyAmount)
                .font(.avenirBodyBold(size: 16))
                .foregroundColor(.neutralHigh)
        }
    }

    private func dateSection(_ details: TransactionDetailsResponse) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Data")
                .font(.avenirBodyRegular(size: 14))
                .foregroundColor(.neutral)
            Text(viewModel.formatDate(details.dateEvent))
                .font(.avenirBodyBold(size: 16))
                .foregroundColor(.neutralHigh)
        }
    }

    private func partySection(title: String, details: AccountDetails) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.avenirBodyRegular(size: 14))
                .foregroundColor(.neutral)
            Text(details.name)
                .font(.avenirBodyBold(size: 16))
                .foregroundColor(.neutralHigh)
            
            Text("\(details.documentType) \(viewModel.formattedDocumentNumber(details.documentNumber))")
                .font(.avenirBodyRegular(size: 14))
                .foregroundColor(.neutral)
            
            Text(details.bankName)
                .font(.avenirBodyRegular(size: 14))
                .foregroundColor(.neutral)
            Text("Agência \(details.agencyNumber) - Conta \(details.accountNumber)")
                .font(.avenirBodyRegular(size: 14))
                .foregroundColor(.neutral)
        }
    }

    private func descriptionSection(_ details: TransactionDetailsResponse) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Descrição")
                .font(.avenirBodyRegular(size: 14))
                .foregroundColor(.neutral)
            Text(details.description)
                .font(.avenirBodyRegular(size: 14))
                .foregroundColor(.neutralHigh)
        }
    }

    private func shareButton(_ details: TransactionDetailsResponse) -> some View {
        CoraButton(
            "ShareReceipt",
            color: .primary,
            icon: .share,
            size: .medium
        ) {
            if let pdfData = viewModel.generatePDF(details: details) {
                onTapShareShareReceipt([pdfData])
            }
        }
    }

    // MARK: - Helpers
    private func icon(for entry: Entry) -> Image {
        switch entry {
        case .debit:
            return Image(Icons.debit.rawValue)
        case .credit:
            return Image(Icons.credit.rawValue)
        case .unknown:
            return Image(systemName: "questionmark.circle")
        }
    }
}

struct TransactionDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionDetailsView(
            viewModel: TransactionDetailsViewModel(),
            transactionId: "abcdef12-3456-7890-abcd-ef1234567890",
            transactionType: .debit,
            onTapShareShareReceipt: { _ in }
        )
    }
}
