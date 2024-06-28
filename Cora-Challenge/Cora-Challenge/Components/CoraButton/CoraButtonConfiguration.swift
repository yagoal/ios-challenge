//
//  CoraButtonConfiguration.swift
//  Cora-Challenge
//
//  Created by Yago Augusto Guedes Pereira on 25/06/24.
//

import SwiftUI

enum CoraButtonVariant {
    case primary
    case text
}

enum CoraButtonIcon: String {
    case arrowRight = "arrow.right"
    case share = "square.and.arrow.up"
    
    var color: Color {
        switch self {
        case .arrowRight: return .white
        case .share: return .init(hex: "#3B3B3B")
        }
    }

    var size: CGFloat {
        switch self {
        case .arrowRight: return 16
        case .share: return 24
        }
    }
}

enum ButtonSize: CGFloat {
    case small = 48
    case medium = 64
    case large = 80

    var fontSize: CGFloat {
        switch self {
        case .small: return 14
        case .medium: return 16
        case .large: return 18
        }
    }
}

struct CoraButtonConfiguration {
    let icon: CoraButtonIcon?
    let size: ButtonSize
    let variant: CoraButtonVariant
    let color: Color

    var backgroundColor: Color {
        switch variant {
        case .primary:
            return color
        case .text:
            return Color.clear
        }
    }
    
    var textColor: Color {
        switch variant {
        case .primary:
            return color == .primary ? .surface : .primary
        case .text:
            return .surface
        }
    }
}
