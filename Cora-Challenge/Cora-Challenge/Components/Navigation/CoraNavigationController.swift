//
//  CoraNavigationController.swift
//  Cora-Challenge
//
//  Created by Yago Augusto Guedes Pereira on 26/06/24.
//

import UIKit
import SwiftUI

final class CoraNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        applyCustomStyle()
//        removeBackButtonTitle()
    }

    private func applyCustomStyle() {
        let appearance = createNavigationBarAppearance()
        if let resizedBackImage = createResizedBackImage() {
            configureBackIndicator(for: appearance, with: resizedBackImage)
        }
        configureNavigationBar(with: appearance)
    }

    private func createNavigationBarAppearance() -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemGray6
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(Color.neutralHigh),
            .font: UIFont(name: "Avenir", size: 14) ?? UIFont.systemFont(ofSize: 14)
        ]
        let barAppearance = UIBarButtonItemAppearance()
        barAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]

        appearance.backButtonAppearance = barAppearance

        return appearance
    }

    private func createResizedBackImage() -> UIImage? {
        guard let backImage = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate) else {
            return nil
        }
        return resizeImage(image: backImage, targetSize: CGSize(width: 12, height: 20))
    }

    private func configureBackIndicator(for appearance: UINavigationBarAppearance, with image: UIImage) {
        let insetImage = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0))
        appearance.setBackIndicatorImage(insetImage, transitionMaskImage: insetImage)
    }

    private func configureNavigationBar(with appearance: UINavigationBarAppearance) {
        navigationBar.tintColor = UIColor(Color.primary)
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
    }

    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
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

}
