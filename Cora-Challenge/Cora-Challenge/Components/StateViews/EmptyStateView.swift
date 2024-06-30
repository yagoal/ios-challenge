//
//  EmptyStateView.swift
//  Cora-Challenge
//
//  Created by Yago Augusto Guedes Pereira on 26/06/24.
//

import SwiftUI

struct EmptyStateView: View {
    let message: LocalizedStringKey

    var body: some View {
        VStack {
            Spacer()
            Text(message)
                .font(.avenirBodyBold(size: 18))
                .foregroundColor(.neutral)
            Spacer()
        }
    }
}

#Preview {
    EmptyStateView(message: "EmptyViewMessage")
}
