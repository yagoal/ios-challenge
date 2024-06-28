//
//  TransactionDetailsResponse.swift
//  Cora-Challenge
//
//  Created by Yago Augusto Guedes Pereira on 27/06/24.
//

import Foundation

import Foundation

struct TransactionDetailsResponse: Decodable {
    let id: String
    let description: String
    let label: String
    let amount: Int
    let counterPartyName: String
    let dateEvent: String
    let recipient: AccountDetails
    let sender: AccountDetails
    let status: String
}

struct AccountDetails: Decodable {
    let bankName: String
    let bankNumber: String
    let documentNumber: String
    let documentType: String
    let accountNumberDigit: String
    let agencyNumberDigit: String
    let agencyNumber: String
    let name: String
    let accountNumber: String
}
