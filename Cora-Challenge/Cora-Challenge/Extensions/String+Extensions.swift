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

    var isCNPJ: Bool {
        let numbers = compactMap({ Int(String($0)) })
        guard numbers.count == 14 && Set(numbers).count != 1 else { return false }
        let sum1 = 11 - ( numbers[11] * 2 +
            numbers[10] * 3 +
            numbers[9] * 4 +
            numbers[8] * 5 +
            numbers[7] * 6 +
            numbers[6] * 7 +
            numbers[5] * 8 +
            numbers[4] * 9 +
            numbers[3] * 2 +
            numbers[2] * 3 +
            numbers[1] * 4 +
            numbers[0] * 5 ) % 11
        let dv1 = sum1 > 9 ? 0 : sum1
        let sum2 = 11 - ( numbers[12] * 2 +
            numbers[11] * 3 +
            numbers[10] * 4 +
            numbers[9] * 5 +
            numbers[8] * 6 +
            numbers[7] * 7 +
            numbers[6] * 8 +
            numbers[5] * 9 +
            numbers[4] * 2 +
            numbers[3] * 3 +
            numbers[2] * 4 +
            numbers[1] * 5 +
            numbers[0] * 6 ) % 11
        let dv2 = sum2 > 9 ? 0 : sum2
        guard dv1 == numbers[12] && dv2 == numbers[13] else { return false }
        return true
    }
}
