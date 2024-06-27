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

class LoginViewModel: ObservableObject {
    @Published var cpf: String = ""
    @Published var password: String = ""
    @Published var isValid: Bool = false
    @Published var errorMessage: String?
    @Published var fieldType: FieldType = .cpf
    
    private var cancellables = Set<AnyCancellable>()
    private let authService: AuthServiceProtocol
    private let keychainHelper = KeychainHelper.shared

    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
        setupFormValidation()
    }
    
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

    private func validate(_ text: String, for fieldType: FieldType) -> Bool {
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

    func authenticate(completion: @escaping (Result<Bool, Error>) -> Void) {
        let cpfNumber = cpf.filter { $0.isNumber }
        authService.authenticate(cpf: cpfNumber, password: password)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
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

    func nextAction(completion: @escaping (Result<Bool, Error>) -> Void) {
        switch fieldType {
        case .cpf:
            completion(.success(true))
        case .password:
            authenticate(completion: completion)
        }
    }
}
