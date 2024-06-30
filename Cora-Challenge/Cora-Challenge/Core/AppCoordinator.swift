//
//  AppCoordinator.swift
//  Cora-Challenge
//
//  Created by Yago Augusto Guedes Pereira on 25/06/24.
//

import UIKit
import SwiftUI

final class AppCoordinator: ObservableObject {
    private let rootViewController: CoraNavigationController

    // MARK: - Initializer
    init(rootViewController: CoraNavigationController) {
        self.rootViewController = rootViewController
    }

    // MARK: - Navigation Methods
    func start() {
        let startView = StartView()
            .onAppear { [weak self] in self?.configureNavigation(isHidden: true) }
            .environmentObject(self)
        let host = UIHostingController(rootView: startView)
        configureNavigation(isHidden: true)
        push(controller: host)
    }

    func showCpfFormLogin() {
        let loginViewModel = LoginViewModel()
        let loginView = LoginView(viewModel: loginViewModel)
            .onAppear { loginViewModel.fieldType = .cpf }
            .environmentObject(self)
        let host = UIHostingController(rootView: loginView)
        configureBackButton(for: host)
        configureNavigation(isHidden: false)
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
        configureNavigation(isHidden: false)
        push(controller: host)
    }

    func showStatementList() {
        let statementListView = StatementListView().environmentObject(self)
        let host = UIHostingController(rootView: statementListView)
        configureBackButton(for: host)
        push(controller: host)
        configureNavigation(isHidden: false, rightButtonImage: "sign-out", rightButtonAction: #selector(signOutAction))
    }

    func showStatementDetails(id: String, transactionType: Entry) {
        let detailsView = TransactionDetailsView(
            transactionId: id,
            transactionType: transactionType,
            onTapShareShareReceipt: { [weak self] items in self?.showShareReceipt(items: items) }
        )

        let host = UIHostingController(rootView: detailsView)
        configureBackButton(for: host)
        configureNavigation(isHidden: false)
        push(controller: host)
    }

    func showShareReceipt(items: [Any]) {
        let customItems = items.map { CustomActivityItemSource(item: $0) }
        let controller = UIActivityViewController(activityItems: customItems, applicationActivities: nil)
        controller.modalPresentationStyle = .formSheet
        present(controller: controller)
    }

    // MARK: - Action Methods
    private func push(controller: UIViewController) {
        rootViewController.pushViewController(controller, animated: true)
    }
    
    private func present(controller: UIViewController) {
        rootViewController.present(controller, animated: true)
    }

    @objc func pop() {
        rootViewController.popViewController(animated: true)
    }

    private func popToRoot() {
        rootViewController.popToRootViewController(animated: true)
    }

    // MARK: - Helper Methods
    private func configureNavigation(isHidden: Bool, rightButtonImage: String? = nil, rightButtonAction: Selector? = nil) {
        rootViewController.isNavigationBarHidden = isHidden
        if let imageName = rightButtonImage, let action = rightButtonAction {
            rootViewController.addRightBarButton(imageName: imageName, target: self, action: action)
        } else {
            rootViewController.topViewController?.navigationItem.rightBarButtonItem = nil
        }
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

    @objc private func signOutAction() {
        let alert = UIAlertController(title: "Sair", message: "Tem certeza que deseja sair?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Sair", style: .destructive, handler: { [weak self] _ in
            self?.popToRoot()
        }))
        rootViewController.present(alert, animated: true, completion: nil)
    }
}
