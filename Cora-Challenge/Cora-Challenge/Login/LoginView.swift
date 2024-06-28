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
    // MARK: - Properties
    @EnvironmentObject var coordinator: AppCoordinator
    @ObservedObject var viewModel: LoginViewModel
    @FocusState private var isFocused: Bool

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerView
            inputFields
            forgotPasswordView
            Spacer()
            nextButton
        }
        .padding(.horizontal, 24)
        .navigationBarTitle("Login Cora", displayMode: .inline)
    }
    
    // MARK: - Views
    private var headerView: some View {
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
    }
    
    private var inputFields: some View {
        Group {
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
        }
    }

    private var forgotPasswordView: some View {
        Group {
            if viewModel.fieldType == .password {
                Text(LocalizedStringKey("ForgotPasswordButtonTitle"))
                    .font(.avenirBodyRegular(size: 14))
                    .foregroundColor(.primary)
                    .padding(.top, 8)
            }
        }
    }

    private var nextButton: some View {
        CoraButton(
            LocalizedStringKey("NextButtonTitle"),
            state: $viewModel.buttonState,
            color: .primary,
            icon: .arrowRight,
            size: .small
        ) {
            nextAction()
        }
        .disabled(!viewModel.isValid)
        .padding(.bottom, 40)
    }
    
    // MARK: - Actions
    private func nextAction() {
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

    private func onViewAppear() {
        viewModel.password = ""
        viewModel.setupFormValidation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isFocused = true
        }
    }
}

#Preview {
    LoginView(viewModel: LoginViewModel())
}
