//
//  StartViewRepresentable.swift
//  Cora-Challenge
//
//  Created by Yago Augusto Guedes Pereira on 25/06/24.
//

import SwiftUI

import SwiftUI

/// A `UIViewControllerRepresentable` that integrates SwiftUI views with UIKit-style navigation
/// using a custom `CoraNavigationController` and `AppCoordinator`.
///
/// This representable provides a bridge between SwiftUI and UIKit, allowing the use of a
/// coordinator pattern for navigation and other view controller management tasks, while still
/// leveraging SwiftUI for the user interface.
///
/// The main purpose is to enable complex navigation flows and state management
/// using UIKit's `UINavigationController` within a SwiftUI environment.
///
/// Usage:
/// ```
/// struct ContentView: View {
///     var body: some View {
///         ArticleStartViewRepresentable()
///     }
/// }
/// ```
struct ArticleStartViewRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = CoraNavigationController

    func makeUIViewController(context: Context) -> CoraNavigationController {
        let navigationController = CoraNavigationController()
        let coordinator = AppCoordinator(rootViewController: navigationController)
        coordinator.start()
        return navigationController
    }

    func updateUIViewController(_ uiViewController: CoraNavigationController, context: Context) {
        // No update logic needed for this use case.
    }
}
