//
//  Int+Extension.swift
//  Cora-Challenge
//
//  Created by Yago Augusto Guedes Pereira on 27/06/24.
//

import Foundation

extension Int {
    var formattedCurrencyAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        if let formattedAmount = formatter.string(from: NSNumber(value: Double(self) / 100)) {
            return formattedAmount
        } else {
            return "R$ 0,00"
        }
    }
}
