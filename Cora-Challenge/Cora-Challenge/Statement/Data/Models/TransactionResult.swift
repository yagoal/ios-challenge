//
//  TransactionResult.swift
//  Cora-Challenge
//
//  Created by Yago Augusto Guedes Pereira on 26/06/24.
//

import Foundation

struct TransactionResponse: Decodable {
    let results: [TransactionResult]
    let itemsTotal: Int
}

struct TransactionResult: Decodable {
    let items: [TransactionItem]
    let date: String
}

struct TransactionItem: Decodable, Identifiable {
    let id: String
    let description: String
    let label: String
    let entry: Entry
    let amount: Int
    let name: String
    let dateEvent: String
    let status: String
}

enum Entry: String, Decodable {
    case debit = "DEBIT"
    case credit = "CREDIT"
    case unknown

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        self = Entry(rawValue: value) ?? .unknown
    }
}
