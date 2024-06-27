//
//  StatementListPlaceHolder.swift
//  Cora-Challenge
//
//  Created by Yago Augusto Guedes Pereira on 26/06/24.
//

import SwiftUI


struct PlaceholderView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(0..<20) { index in
                    if index % 4 == 0 {
                        PlaceholderSection()
                    }
                    PlaceholderCell()
                }
            }
        }
    }
}

private struct PlaceholderCell: View {
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
        .padding(.horizontal, 24)
    }
}

private struct PlaceholderSection: View {
    var body: some View {
        ShimmerView(color: .gray.opacity(0.2))
            .frame(height: 30)
            .cornerRadius(5)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    PlaceholderView()
}
