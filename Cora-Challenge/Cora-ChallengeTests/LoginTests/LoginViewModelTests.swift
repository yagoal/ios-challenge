//
//  LoginViewModelTests.swift
//  Cora-ChallengeTests
//
//  Created by Yago Augusto Guedes Pereira on 28/06/24.
//

import Combine
import XCTest
@testable import Cora_Challenge

final class LoginViewModelTests: XCTestCase {
    private var sut: LoginViewModel!
    private var mockAuthService: MockAuthService!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthService()
        sut = LoginViewModel(authService: mockAuthService)
        cancellables = []
    }

    override func tearDown() {
        sut = nil
        mockAuthService = nil
        cancellables = nil
        super.tearDown()
    }

    func test_givenInvalidCpf_whenValidateField_thenReturnFalse() {
        // given
        sut.fieldType = .cpf
        
        // when
        sut.cpf = "123.456.789-09"
        let result = sut.validate(sut.cpf, for: .cpf)

        // then
        XCTAssertFalse(result)
    }

    func test_givenValidCpf_whenValidateField_thenReturnTrue() {
        // given
        sut.fieldType = .cpf
        
        // when
        sut.cpf = "636.774.744-34"
        let result = sut.validate(sut.cpf, for: .cpf)

        // then
        XCTAssertTrue(result)
    }

    func test_givenInvalidPassword_whenValidateField_thenReturnFalse() {
        // given
        sut.fieldType = .password
        
        // when
        sut.password = "12345"
        let result = sut.validate(sut.password, for: .password)

        // then
        XCTAssertFalse(result)
    }

    func test_givenValidPassword_whenValidateField_thenReturnTrue() {
        // given
        sut.fieldType = .password
        
        // when
        sut.password = "123456"
        let result = sut.validate(sut.password, for: .password)

        // then
        XCTAssertTrue(result)
    }

    func test_givenSuccessfulAuthentication_whenAuthenticate_thenReturnSuccess() {
        // given
        let expectation = XCTestExpectation(description: "Authentication should succeed")
        mockAuthService.shouldReturnError = false
        sut.cpf = "111.444.777-35"
        sut.password = "123456"
        sut.fieldType = .password

        // when
        sut.authenticate { result in
            // then
            switch result {
            case .success:
                XCTAssertTrue(true)
                expectation.fulfill()
            case .failure:
                XCTFail("Authentication should succeed")
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }

    func test_givenFailedAuthentication_whenAuthenticate_thenReturnFailure() {
        // given
        let expectation = XCTestExpectation(description: "Authentication should fail")
        mockAuthService.shouldReturnError = true
        sut.cpf = "111.444.777-35"
        sut.password = "123456"
        sut.fieldType = .password

        // when
        sut.authenticate { result in
            // then
            switch result {
            case .success:
                XCTFail("Authentication should fail")
            case .failure:
                XCTAssertTrue(true)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }

    func test_givenCpfFieldType_whenNextAction_thenReturnSuccess() {
        // given
        let expectation = XCTestExpectation(description: "Next action with CPF should succeed")
        sut.fieldType = .cpf

        // when
        sut.nextAction { result in
            // then
            switch result {
            case .success:
                XCTAssertTrue(true)
                expectation.fulfill()
            case .failure:
                XCTFail("Next action with CPF should succeed")
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func test_givenPasswordFieldType_whenNextAction_thenAuthenticate() {
        // given
        let expectation = XCTestExpectation(description: "Next action with password should authenticate")
        mockAuthService.shouldReturnError = false
        sut.cpf = "111.444.777-35"
        sut.password = "123456"
        sut.fieldType = .password

        // when
        sut.nextAction { result in
            // then
            switch result {
            case .success:
                XCTAssertTrue(true)
                expectation.fulfill()
            case .failure:
                XCTFail("Next action with password should succeed")
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }
}
