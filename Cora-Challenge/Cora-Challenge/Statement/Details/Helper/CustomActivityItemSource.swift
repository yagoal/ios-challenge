//
//  CustomActivityItemSource.swift
//  Cora-Challenge
//
//  Created by Yago Augusto Guedes Pereira on 29/06/24.
//
import UIKit
import CoreServices
import LinkPresentation

final class CustomActivityItemSource: NSObject, UIActivityItemSource {
    let item: Any
    
    init(item: Any) {
        self.item = item
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return item
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return item
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = "Comprovante de Transferência"
        
        if let image = UIImage(named: "icon-app"), let data = image.pngData() {
            metadata.iconProvider = NSItemProvider(item: data as NSData, typeIdentifier: kUTTypePNG as String)
        }
        
        return metadata
    }
}
