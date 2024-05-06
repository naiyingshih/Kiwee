//
//  UIButton+Extension.swift
//  Kiwee
//
//  Created by NY on 2024/5/6.
//

import UIKit

extension UIButton {
    
    func applyPrimaryStyle(size: CGFloat) {
        self.setTitleColor(.white, for: .normal)
        self.layer.cornerRadius = 10
        self.backgroundColor = KWColor.darkB
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        self.titleLabel?.font = UIFont.regular(size: size)
    }
    
    func applySecondaryStyle(size: CGFloat) {
        self.setTitleColor(KWColor.darkB, for: .normal)
        self.layer.cornerRadius = 10
        self.backgroundColor = KWColor.darkB.withAlphaComponent(0.2)
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        self.titleLabel?.font = UIFont.regular(size: size)
    }
    
    func applyThirdStyle(size: CGFloat) {
        self.setTitleColor(KWColor.darkB, for: .normal)
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 1.0
        self.layer.borderColor = KWColor.darkB.cgColor
        self.backgroundColor = .white
        self.titleLabel?.font = UIFont.regular(size: size)
        self.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
}
