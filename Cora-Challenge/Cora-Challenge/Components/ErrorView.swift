//
//  ErrorView.swift
//  Cora-Challenge
//
//  Created by Yago Augusto Guedes Pereira on 26/06/24.
//

import SwiftUI

struct ErrorView: View {
    let message: LocalizedStringKey
    let retryAction: () -> Void

    var body: some View {
        VStack {
            Spacer()
            Text(message)
                .foregroundColor(.red)
                .padding()
            Spacer()
            CoraButton("Retry", action: retryAction)
                .padding()
         
        }
    }
}

#Preview {
    ErrorView(message: "Algo deu errado", retryAction: {})
}
