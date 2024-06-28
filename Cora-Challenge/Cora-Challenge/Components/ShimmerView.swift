//
//  ShimmerView.swift
//  Cora-Challenge
//
//  Created by Yago Augusto Guedes Pereira on 26/06/24.
//

import SwiftUI

struct ShimmerView: View {
    @State private var startPoint = UnitPoint(x: -1, y: 0.5)
    @State private var endPoint = UnitPoint(x: 1, y: 0.5)
    var color: Color = .gray.opacity(0.4)
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [color, color.opacity(0.3), color]),
                    startPoint: startPoint,
                    endPoint: endPoint
                )
            )
            .onAppear {
                withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    startPoint = UnitPoint(x: 1, y: 0.5)
                    endPoint = UnitPoint(x: 2, y: 0.5)
                }
            }
    }
}

#Preview {
    ShimmerView()
}
