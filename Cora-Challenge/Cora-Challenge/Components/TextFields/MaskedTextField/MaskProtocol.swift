//
//  MaskProtocol.swift
//  Cora-Challenge
//
//  Created by Yago Augusto Guedes Pereira on 25/06/24.
//

import Foundation

/// A protocol defining a mask format for formatting text.
public protocol Mask {
    var maskFormat: String { get set }
    func formateValue(_ value: String) -> String
}

extension Mask {
    public func formateValue(_ value: String) -> String {
        let cleanNumber = value.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let mask = maskFormat
        var result = ""
        var index = cleanNumber.startIndex
        for ch in mask where index < cleanNumber.endIndex {
            if ch == "#" {
                result.append(cleanNumber[index])
                index = cleanNumber.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
    }
}

/// A concrete implementation of the `Mask` protocol for formatting CPF numbers.
struct CPFMask: Mask {
    public var maskFormat: String = "###.###.###-##"
}
