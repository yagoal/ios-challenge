//
//  PasswordField.swift
//  Cora-Challenge
//
//  Created by Yago Augusto Guedes Pereira on 25/06/24.
//

import SwiftUI

struct PasswordField: View {
    @Binding private var text: String
    @State private var isSecured: Bool = true

    private let placeholder: String

    init(placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if isSecured {
                    SecureField(placeholder, text: $text)
                        .font(.avenirBodyRegular(size: 22))
                } else {
                    TextField(placeholder, text: $text)
                        .font(.avenirBodyRegular(size: 22))
                }
                
                Button(action: {
                    isSecured.toggle()
                }) {
                    Image(systemName: isSecured ? "eye.slash" : "eye")
                        .foregroundColor(.primary)
                }
            }
            .padding(.vertical, 10)
            .background(Color.clear)
            .cornerRadius(8)
        }
    }
}
