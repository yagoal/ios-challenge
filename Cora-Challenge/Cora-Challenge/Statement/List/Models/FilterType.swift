//
//  FilterType.swift
//  Cora-Challenge
//
//  Created by Yago Augusto Guedes Pereira on 27/06/24.
//

import Foundation

enum FilterType: String, CaseIterable {
    case all = "Tudo"
    case income = "Entrada"
    case expense = "Saída"
    case future = "Futuro"
}

enum SortOrder {
    case recent
    case oldest
}
