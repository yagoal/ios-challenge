//
//  MaskProtocol.swift
//  Cora-Challenge
//
//  Created by Yago Augusto Guedes Pereira on 26/06/24.
//

import SwiftUI
import Combine


struct MaskedTextField: View {
    @Binding private var text: String
    private let placeholder: String
    private let mask: Mask?
    
    public init(placeholder: String, text: Binding<String>, mask: Mask? = nil) {
        self.placeholder = placeholder
        self._text = text
        self.mask = mask
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField(placeholder, text: $text)
                .font(.avenirBodyRegular(size: 22))
                .keyboardType(.numberPad)
                .onReceive(Just(text)) { newValue in
                    let formattedText = mask?.formateValue(newValue) ?? newValue
                    if formattedText != newValue {
                        self.text = formattedText
                    }
                }
        }
    }
}

