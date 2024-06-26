//
//  LoginView.swift
//  Cora-Challenge
//
//  Created by Yago Augusto Guedes Pereira on 25/06/24.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel: LoginViewModel
    @FocusState private var isFocused: Bool
    
    init(fieldType: FieldType) {
        _viewModel = StateObject(wrappedValue: LoginViewModel(fieldType: fieldType))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                if viewModel.fieldType == .cpf {
                    Text(LocalizedStringKey("WelcomeBack"))
                        .font(.avenirBodyRegular(size: 16))
                        .foregroundColor(.primaryText)
                        .padding(.top, 16)
                    
                    Text(LocalizedStringKey("EnterYourCPF"))
                        .font(.avenirBodyBold(size: 22))
                        .foregroundColor(.primaryTextHigh)
                        .padding(.top, 8)
                } else {
                    Text(LocalizedStringKey("EnterYourPassword"))
                        .font(.avenirBodyBold(size: 22))
                        .foregroundColor(.primaryTextHigh)
                        .padding(.top, 16)
                }
            }
    
            if viewModel.fieldType == .cpf {
                MaskedTextField(
                    placeholder: "",
                    text: $viewModel.text,
                    mask: CPFMask()
                )
                .padding(.top, 16)
                .focused($isFocused)
                .onAppear { onViewAppear() }
            } else {
                PasswordField(
                    placeholder: "",
                    text: $viewModel.text
                )
                .padding(.top, 16)
                .focused($isFocused)
                .onAppear { onViewAppear() }
            }

            if viewModel.fieldType == .password {
                Text(LocalizedStringKey("ForgotPasswordButtonTitle"))
                    .font(.avenirBodyRegular(size: 14))
                    .foregroundColor(.primary)
                    .padding(.top, 8)
            }

            Spacer()

            CoraButton(
                LocalizedStringKey("NextButtonTitle"),
                color: .primary,
                icon: .arrowRight,
                size: .small
            ) {
                nextAction()
            }
            .environment(\.isEnabled, viewModel.isValid)
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 24)
        .navigationBarTitle("Login Cora", displayMode: .inline)
    }

    private func onViewAppear() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isFocused = true
        }
    }

    private func nextAction() {
        switch viewModel.fieldType {
        case .cpf:
            coordinator.showPasswordFormLogin()
        case .password:
            // Implement password handling
            break
        }
    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoginView(fieldType: .cpf)
            LoginView(fieldType: .password)
        }
    }
}
