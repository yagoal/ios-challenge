//
//  AppCoordinator.swift
//  Cora-Challenge
//
//  Created by Yago Augusto Guedes Pereira on 25/06/24.
//

import UIKit
import SwiftUI

final class AppCoordinator: ObservableObject {
    private let rootViewController: UINavigationController

    init(rootViewController: UINavigationController) {
        self.rootViewController = rootViewController
    }

    func start() {
        let startView = StartView()
            .onAppear { [weak self] in self?.setupHiddenNavigation(isHidden: true) }
            .environmentObject(self)
        let host = UIHostingController(rootView: startView)
        rootViewController.isNavigationBarHidden = true
        push(controller: host)
    }

    func showCpfFormLogin() {
        let loginViewModel = LoginViewModel()
        let loginView = LoginView(viewModel: loginViewModel)
            .onAppear { loginViewModel.fieldType = .cpf }
            .environmentObject(self)
        let host = UIHostingController(rootView: loginView)
        configureBackButton(for: host)
        rootViewController.isNavigationBarHidden = false
        push(controller: host)
    }

    func showPasswordFormLogin(viewModel: LoginViewModel) {
        let loginView = LoginView(viewModel: viewModel)
            .onAppear {
                viewModel.isValid = false
                viewModel.fieldType = .password
            }
            .environmentObject(self)
        let host = UIHostingController(rootView: loginView)
        configureBackButton(for: host)
        setupHiddenNavigation(isHidden: false)
        push(controller: host)
    }

    func showStatementList() {
        let statementListView = StatementListView().environmentObject(self)
        let host = UIHostingController(rootView: statementListView)
        configureBackButton(for: host)
        setupHiddenNavigation(isHidden: false)
        push(controller: host)
    }
    
    private func setupHiddenNavigation(isHidden: Bool) {
        rootViewController.isNavigationBarHidden = isHidden
    }

    private func push(controller: UIViewController) {
        rootViewController.pushViewController(controller, animated: true)
    }

    @objc func pop() {
        rootViewController.popViewController(animated: true)
    }

    private func configureBackButton(for hostingController: UIHostingController<some View>) {
        let backButton = UIBarButtonItem(
            title: "",
            style: .plain,
            target: nil,
            action: #selector(pop)
        )
        hostingController.navigationItem.backBarButtonItem = backButton
    }
}
