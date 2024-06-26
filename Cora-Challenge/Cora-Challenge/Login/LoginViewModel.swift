//
//  LoginViewModel.swift
//  Cora-Challenge
//
//  Created by Yago Augusto Guedes Pereira on 25/06/24.
//

import SwiftUI
import Combine

enum FieldType {
    case cpf
    case password
}

class LoginViewModel: ObservableObject {
    @Published var text: String = ""
    @Published var isValid: Bool = false
    let fieldType: FieldType
    private var cancellables = Set<AnyCancellable>()
    
    init(fieldType: FieldType) {
        self.fieldType = fieldType
        setupFormValidation()
    }
    
    private func setupFormValidation() {
        $text
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
}
