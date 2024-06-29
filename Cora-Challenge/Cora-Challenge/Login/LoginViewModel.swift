//
//  LoginViewModel.swift
//  Cora-Challenge
//
//  Created by Yago Augusto Guedes Pereira on 25/06/24.
//

import Foundation
import Combine

enum FieldType {
    case cpf
    case password
}

final class LoginViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var cpf: String = ""
    @Published var password: String = ""
    @Published var isValid: Bool = false
    @Published var errorMessage: String?
    @Published var fieldType: FieldType = .cpf
    @Published var buttonState: CoraButtonState = .default
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let authService: AuthServiceProtocol
    private let keychainHelper = KeychainHelper.shared

    // MARK: - Initializer
    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
        setupFormValidation()
    }
    
    // MARK: - Form Validation Setup
    func setupFormValidation() {
        switch fieldType {
        case .cpf:
            setupCpfValidation()
        case .password:
            setupPasswordValidation()
        }
    }
    
    private func setupCpfValidation() {
        $cpf
            .receive(on: DispatchQueue.main)
            .map { [weak self] text in
                guard let self else { return false }
                return self.validate(text, for: self.fieldType)
            }
            .assign(to: \.isValid, on: self)
            .store(in: &cancellables)
    }

    private func setupPasswordValidation() {
        $password
            .receive(on: DispatchQueue.main)
            .map { [weak self] text in
                guard let self else { return false }
                return self.validate(text, for: self.fieldType)
            }
            .assign(to: \.isValid, on: self)
            .store(in: &cancellables)
    }

    // MARK: - Validation Methods
    func validate(_ text: String, for fieldType: FieldType) -> Bool {
        switch fieldType {
        case .cpf:
            let cleanedText = text.filter { $0.isNumber }
            return cleanedText.isCPF
        case .password:
            return validatePassword(text)
        }
    }

    private func validatePassword(_ password: String) -> Bool {
        return password.count >= 6
    }

    // MARK: - Authentication
    func authenticate(completion: @escaping (Result<Bool, Error>) -> Void) {
        let cpfNumber = cpf.filter { $0.isNumber }
        buttonState = .loading
        authService.authenticate(cpf: cpfNumber, password: password)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                self?.buttonState = .default
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                }
            }, receiveValue: { [weak self] response in
                self?.keychainHelper.saveToken(response.token)
                completion(.success(true))
            })
            .store(in: &cancellables)
    }

    // MARK: - Aux Navigation Methods
    func nextAction(completion: @escaping (Result<Bool, Error>) -> Void) {
        switch fieldType {
        case .cpf:
            completion(.success(true))
        case .password:
            authenticate(completion: completion)
        }
    }
}
