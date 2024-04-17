//
//  ReportViewCell.swift
//  Kiwee
//
//  Created by NY on 2024/4/15.
//

import UIKit
import SwiftUI

class SwiftUIHostingCell: UICollectionViewCell {
    private var hostingController: UIHostingController<AnyView>?

    func host(contentView: AnyView, parentViewController: UIViewController) {
        // Remove the previous hosting controller if it exists
        if let existingHostingController = hostingController {
            existingHostingController.willMove(toParent: nil)
            existingHostingController.view.removeFromSuperview()
            existingHostingController.removeFromParent()
        }

        // Create a new hosting controller with the SwiftUI view
        let newHostingController = UIHostingController(rootView: contentView)
        parentViewController.addChild(newHostingController)
        contentViewContainer.addSubview(newHostingController.view)
        newHostingController.view.frame = contentViewContainer.bounds
        newHostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        newHostingController.didMove(toParent: parentViewController)
        newHostingController.view.layer.cornerRadius = 10
        newHostingController.view.layer.borderWidth = 3
        newHostingController.view.layer.borderColor = UIColor.systemYellow.cgColor

        // Keep a reference to the new hosting controller
        hostingController = newHostingController
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        hostingController?.willMove(toParent: nil)
        hostingController?.view.removeFromSuperview()
        hostingController?.removeFromParent()
        hostingController = nil
    }

    private lazy var contentViewContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.leftAnchor.constraint(equalTo: leftAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
            view.rightAnchor.constraint(equalTo: rightAnchor)
        ])
        return view
    }()
}