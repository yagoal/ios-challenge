//
//  LoginView.swift
//  Cora-Challenge
//
//  Created by Yago Augusto Guedes Pereira on 25/06/24.
//

import SwiftUI
import Combine

import SwiftUI
import Combine

struct LoginView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @ObservedObject var viewModel: LoginViewModel
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                if viewModel.fieldType == .cpf {
                    Text(LocalizedStringKey("WelcomeBack"))
                        .font(.avenirBodyRegular(size: 16))
                        .foregroundColor(.neutral)
                        .padding(.top, 16)
                    
                    Text(LocalizedStringKey("EnterYourCPF"))
                        .font(.avenirBodyBold(size: 22))
                        .foregroundColor(.neutralHigh)
                        .padding(.top, 8)
                } else {
                    Text(LocalizedStringKey("EnterYourPassword"))
                        .font(.avenirBodyBold(size: 22))
                        .foregroundColor(.neutralHigh)
                        .padding(.top, 16)
                }
            }
    
            if viewModel.fieldType == .cpf {
                MaskedTextField(
                    placeholder: "",
                    text: $viewModel.cpf,
                    mask: CPFMask()
                )
                .padding(.top, 16)
                .focused($isFocused)
                .onAppear { onViewAppear() }
            } else {
                PasswordField(
                    placeholder: "",
                    text: $viewModel.password
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
                viewModel.nextAction { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            if viewModel.fieldType == .cpf {
                                coordinator.showPasswordFormLogin(viewModel: viewModel)
                            } else {
                                coordinator.showStatementList()
                            }
                        case .failure(let error):
                            print("Authentication failed: \(error.localizedDescription)")
                        }
                    }
                }
            }
            .environment(\.isEnabled, viewModel.isValid)
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 24)
        .navigationBarTitle("Login Cora", displayMode: .inline)
    }

    private func onViewAppear() {
        viewModel.password = ""
        viewModel.setupFormValidation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isFocused = true
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoginView(viewModel: LoginViewModel())
            LoginView(viewModel: LoginViewModel())
        }
    }
}
