//
//  StartViewRepresentable.swift
//  Cora-Challenge
//
//  Created by Yago Augusto Guedes Pereira on 25/06/24.
//

import SwiftUI

struct ArticleStartViewRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = CoraNavigationController

    func makeUIViewController(context: Context) -> CoraNavigationController {
        let navigationController = CoraNavigationController()
        let coordinator = AppCoordinator(rootViewController: navigationController)
        coordinator.start()
        return navigationController
    }

    func updateUIViewController(_ uiViewController: CoraNavigationController, context: Context) {
    }
}
