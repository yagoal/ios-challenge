//
//  CoraNavigationController.swift
//  Cora-Challenge
//
//  Created by Yago Augusto Guedes Pereira on 26/06/24.
//

import UIKit
import SwiftUI

/// A custom navigation controller that applies a specific style to the navigation bar and provides utility methods
/// for adding custom navigation bar buttons.
final class CoraNavigationController: UINavigationController {

    // MARK: - Lifecycle
    /// Called after the controller’s view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        applyCustomStyle()
    }

    // MARK: - Style Configuration

    /// Applies custom styles to the navigation bar.
    private func applyCustomStyle() {
        let appearance = createNavigationBarAppearance()
        if let resizedBackImage = createResizedBackImage() {
            configureBackIndicator(for: appearance, with: resizedBackImage)
        }
        configureNavigationBar(with: appearance)
    }

    /// Creates a custom appearance for the navigation bar.
    /// - Returns: A configured `UINavigationBarAppearance` object.
    private func createNavigationBarAppearance() -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemGray6
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(Color.neutralHigh),
            .font: UIFont.avenir(size: 14)
        ]
        let barAppearance = UIBarButtonItemAppearance()
        barAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        appearance.backButtonAppearance = barAppearance
        return appearance
    }

    /// Creates a resized back image for the navigation bar.
    /// - Returns: A resized `UIImage` for the back button.
    private func createResizedBackImage() -> UIImage? {
        guard let backImage = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate) else {
            return nil
        }
        return resizeImage(image: backImage, targetSize: CGSize(width: 12, height: 20))
    }

    /// Configures the back indicator image for the navigation bar.
    /// - Parameters:
    ///   - appearance: The `UINavigationBarAppearance` to configure.
    ///   - image: The back indicator `UIImage` to use.
    private func configureBackIndicator(for appearance: UINavigationBarAppearance, with image: UIImage) {
        let insetImage = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0))
        appearance.setBackIndicatorImage(insetImage, transitionMaskImage: insetImage)
    }

    /// Applies the custom appearance to the navigation bar.
    /// - Parameter appearance: The `UINavigationBarAppearance` to apply.
    private func configureNavigationBar(with appearance: UINavigationBarAppearance) {
        navigationBar.tintColor = UIColor(Color.primary)
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
    }

    // MARK: - Image Resizing
    
    /// Resizes an image to the specified target size.
    /// - Parameters:
    ///   - image: The `UIImage` to resize.
    ///   - targetSize: The desired target size.
    /// - Returns: A resized `UIImage`.
    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        let rect = CGRect(origin: .zero, size: newSize)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    // MARK: - Navigation Bar Buttons
    
    /// Adds a custom right bar button to the navigation bar.
    /// - Parameters:
    ///   - imageName: The name of the image asset to use for the button.
    ///   - target: The target object—that is, the object to which the action message is sent.
    ///   - action: The action to send to target when this item is selected.
    func addRightBarButton(imageName: String, target: Any?, action: Selector) {
        guard let rightImage = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate) else {
            return
        }
        let resizedRightImage = resizeImage(image: rightImage, targetSize: CGSize(width: 24, height: 24))
        let rightBarButtonItem = UIBarButtonItem(
            image: resizedRightImage,
            style: .plain,
            target: target,
            action: action
        )
        topViewController?.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
}
