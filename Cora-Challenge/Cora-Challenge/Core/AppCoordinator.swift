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

    init(rootViewController: CoraNavigationController) {
        self.rootViewController = rootViewController
    }

    func start() {
        let startView = StartView()
            .onAppear { [weak self] in self?.setNavigationBarHidden(isHidden: true) }
            .environmentObject(self)
        let host = UIHostingController(rootView: startView)
        configureBackButton(for: host)

        push(controller: host)
    }

    func showCpfFormLogin() {
        let loginView = LoginView(fieldType: .cpf).environmentObject(self)
        let host = UIHostingController(rootView: loginView)
        configureBackButton(for: host)
        setNavigationBarHidden(isHidden: false)
        push(controller: host)
    }

    func showPasswordFormLogin() {
        let loginView = LoginView(fieldType: .password).environmentObject(self)
        let host = UIHostingController(rootView: loginView)
        configureBackButton(for: host)
        setNavigationBarHidden(isHidden: false)
        push(controller: host)
    }

    private func push(controller: UIViewController) {
        rootViewController.pushViewController(controller, animated: true)
    }

    private func setNavigationBarHidden(isHidden: Bool) {
        rootViewController.isNavigationBarHidden = isHidden
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
