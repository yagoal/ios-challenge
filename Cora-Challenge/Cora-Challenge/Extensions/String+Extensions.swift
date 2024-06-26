//
//  String+Extensions.swift
//  Cora-Challenge
//
//  Created by Yago Augusto Guedes Pereira on 25/06/24.
//

import Foundation

extension String {
    var isCPF: Bool {
        let invalidDocuments = [
            "00000000000",
            "11111111111",
            "22222222222",
            "33333333333",
            "44444444444",
            "55555555555",
            "66666666666",
            "77777777777",
            "88888888888",
            "99999999999",
            "12345678909",
        ]

        let numbersOnly = self.filter { $0.isNumber }
        
        guard
            numbersOnly.count == 11,
            rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil,
            !invalidDocuments.contains(numbersOnly)
        else {
            return false
        }

        let tenthDigitIndex = numbersOnly.index(numbersOnly.startIndex, offsetBy: 9)
        let eleventhDigitIndex = numbersOnly.index(numbersOnly.startIndex, offsetBy: 10)

        let d10 = Int(String(numbersOnly[tenthDigitIndex]))
        let d11 = Int(String(numbersOnly[eleventhDigitIndex]))

        var resultModuleOne = 0, resultModuleTwo = 0

        for i in 0...8 {
            let charIndex = numbersOnly.index(numbersOnly.startIndex, offsetBy: i)
            let char = Int(String(numbersOnly[charIndex]))

            resultModuleOne += (char ?? 0) * (10 - i)
            resultModuleTwo += (char ?? 0) * (11 - i)
        }

        resultModuleOne %= 11
        resultModuleOne = (resultModuleOne < 2) ? 0 : (11 - resultModuleOne)

        resultModuleTwo += resultModuleOne * 2
        resultModuleTwo %= 11
        resultModuleTwo = (resultModuleTwo < 2) ? 0 : (11 - resultModuleTwo)

        guard resultModuleOne == d10 && resultModuleTwo == d11 else { return false }
        return true
    }
}
