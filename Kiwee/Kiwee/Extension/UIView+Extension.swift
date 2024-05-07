//
//  UIView+Extension.swift
//  Kiwee
//
//  Created by NY on 2024/4/29.
//

import UIKit

extension UIView {

    func applyGradient(isVertical: Bool, colorArray: [UIColor]) {
        layer.sublayers?.filter({ $0 is CAGradientLayer }).forEach({ $0.removeFromSuperlayer() })

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colorArray.map({ $0.cgColor })
        if isVertical {
            // top to bottom
            gradientLayer.locations = [0.0, 1.0]
        } else {
            // left to right
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        }

        backgroundColor = .clear
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func addTopBorder(color: UIColor, width: CGFloat) {
        let topBorderView = UIView(frame: CGRect.zero)
        topBorderView.backgroundColor = color
        self.addSubview(topBorderView)
        topBorderView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topBorderView.topAnchor.constraint(equalTo: self.topAnchor),
            topBorderView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            topBorderView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            topBorderView.heightAnchor.constraint(equalToConstant: width)
        ])
    }
    
    func applyCardStyle(backgroundColor: UIColor = KWColor.cardBackground) {
        self.backgroundColor = backgroundColor
        self.layer.cornerRadius = 10
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 5
    }

}
