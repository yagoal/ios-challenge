//
//  Font+Extension.swift
//  Cora-Challenge
//
//  Created by Yago Augusto Guedes Pereira on 25/06/24.
//

import SwiftUI

extension Font {
    static func avenir(size: CGFloat = 16, weight: Font.Weight = .regular) -> Font {
        return Font.custom("Avenir", size: size).weight(weight)
    }

    static func avenirBodyRegular(size: CGFloat = 16) -> Font {
        return avenir(size: size, weight: .regular)
    }

    static func avenirBodyBold(size: CGFloat = 16) -> Font {
        return avenir(size: size, weight: .bold)
    }
}
