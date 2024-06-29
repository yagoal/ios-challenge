//
//  TransactionCellViewData.swift
//  Cora-Challenge
//
//  Created by Yago Augusto Guedes Pereira on 26/06/24.
//

import SwiftUI

struct TransactionCellViewData: Equatable {
    let id: String
    let color: Color
    let icon: Image
    let amount: String
    let label: String
    let name: String
    let hour: String

    init(item: TransactionItem) {
        id = item.id
        color = Self.color(for: item.entry)
        icon = Self.icon(for: item.entry)
        amount = item.amount.formattedCurrencyAmount
        label = item.label
        name = item.name
        hour = Self.formatHour(from: item.dateEvent)
    }

    private static func color(for entry: Entry) -> Color {
        switch entry {
        case .debit:
            return .black
        case .credit:
            return .primaryBlue
        case .unknown:
            return .gray
        }
    }

    private static func icon(for entry: Entry) -> Image {
        switch entry {
        case .debit:
            return Image(Icons.debit.rawValue)
        case .credit:
            return Image(Icons.credit.rawValue)
        case .unknown:
            return Image(systemName: "questionmark.circle")
        }
    }

    private static func formatHour(from dateEvent: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let date = dateFormatter.date(from: dateEvent) {
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter.string(from: date)
        } else {
            return "Invalid date"
        }
    }
}

enum Icons: String {
    case credit = "arrow-down-in"
    case debit = "arrow-up-out"
}
