//
//  Font+Extension.swift
//  Cora-Challenge
//
//  Created by Yago Augusto Guedes Pereira on 25/06/24.
//

import SwiftUI
import UIKit

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

extension UIFont {
    static func avenir(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        switch weight {
        case .bold:
            return UIFont(name: "Avenir-Black", size: size) ?? .systemFont(ofSize: size, weight: weight)
        case .medium:
            return UIFont(name: "Avenir-Medium", size: size) ?? .systemFont(ofSize: size, weight: weight)
        default:
            return UIFont(name: "Avenir-Book", size: size) ?? .systemFont(ofSize: size, weight: weight)
        }
    }
}
