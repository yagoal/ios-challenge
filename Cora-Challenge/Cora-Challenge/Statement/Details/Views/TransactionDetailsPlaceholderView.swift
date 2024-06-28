//
//  Views.swift
//  Cora-Challenge
//
//  Created by Yago Augusto Guedes Pereira on 27/06/24.
//

import SwiftUI

struct TransactionDetailsPlaceholderView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                PlaceholderHeader()
                ForEach(0..<6) { _ in
                    PlaceholderDetailCell()
                }
            }
            .padding()
        }
    }
}

private struct PlaceholderHeader: View {
    var body: some View {
        ShimmerView(color: .gray.opacity(0.2))
            .frame(height: 30)
            .cornerRadius(5)
            .frame(maxWidth: UIScreen.main.bounds.width * 0.8, alignment: .leading)
    }
}

private struct PlaceholderDetailCell: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ShimmerView()
                .frame(height: 40)
                .cornerRadius(5)
                .frame(maxWidth: UIScreen.main.bounds.width * 0.6, alignment: .leading)
            ShimmerView()
                .frame(height: 20)
                .cornerRadius(5)
                .frame(maxWidth: UIScreen.main.bounds.width * 0.4, alignment: .leading)
        }
    }
}

#Preview {
    TransactionDetailsPlaceholderView()
}
