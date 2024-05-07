//
//  UILabel+Extension.swift
//  Kiwee
//
//  Created by NY on 2024/5/6.
//

import UIKit

extension UILabel {
    
    func applyTitle(size: CGFloat, color: UIColor) {
        self.font = UIFont.medium(size: size)
        self.adjustsFontForContentSizeCategory = true
        self.textColor = color
        self.numberOfLines = 0
    }
    
    func applyContent(size: CGFloat, color: UIColor) {
        self.font = UIFont.regular(size: size)
        self.adjustsFontForContentSizeCategory = true
        self.textColor = color
        self.numberOfLines = 0
    }
    
}
