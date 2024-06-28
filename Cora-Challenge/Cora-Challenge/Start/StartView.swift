//
//  StartView.swift
//  Cora-Challenge
//
//  Created by Yago Augusto Guedes Pereira on 25/06/24.
//

import SwiftUI

struct StartView: View {
    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        VStack {
            VStack(spacing: 0) {
                topView
                bottomView
            }
        }
        .background(Color.primary.edgesIgnoringSafeArea(.all))
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Top View
    private var topView: some View {
        ZStack(alignment: .topLeading) {
            Image("unsplash-login")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 300)
                .clipped()
                .mask(BottomCurveShape().fill(Color.white))
            
            Image("cora-logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 90, height: 24)
                .padding(.top, 20)
                .padding(.leading, 20)
        }
    }
    
    // MARK: - Bottom View
    private var bottomView: some View {
        VStack {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(LocalizedStringKey("StartTitle"))
                        .font(.avenirBodyRegular(size: 28))
                        .foregroundColor(.surface)
                    
                    Text(LocalizedStringKey("StartTitleComplement"))
                        .font(.avenirBodyRegular(size: 28))
                        .foregroundColor(.surface)
                }

                Text(LocalizedStringKey("StartDescription"))
                    .font(.avenirBodyRegular(size: 16))
                    .foregroundColor(.surface)
                    .padding(.bottom, 20)

                Spacer()

                buttonsView
            }
            .padding(.horizontal, 24)
            .background(Color.primary)
        }
        .padding(.top, 16)
    }

    // MARK: - Buttons View
    private var buttonsView: some View {
        VStack(spacing: 24) {
            CoraButton(
                LocalizedStringKey("PrimaryButtonTitle"),
                color: .surface,
                icon: .arrowRight
            ) {
                // Ação do botão
            }

            CoraButton(
                LocalizedStringKey("PrimarySecondaryButtonTitle"),
                color: .clear,
                size: .small,
                variant: .text
            ) {
                coordinator.showCpfFormLogin()
            }
        }
        .padding(.bottom)
    }
}

// MARK: - BottomCurveShape

/// A custom `Shape` that creates a bottom curve effect for the image mask.
private struct BottomCurveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - 100))
        path.addQuadCurve(to: CGPoint(x: 0, y: rect.height - 50), control: CGPoint(x: rect.width / 2, y: rect.height + 60))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.closeSubpath()

        return path
    }
}

#Preview {
    StartView()
}
