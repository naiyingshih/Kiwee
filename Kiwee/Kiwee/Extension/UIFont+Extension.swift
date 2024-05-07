//
//  UIFont+Extension.swift
//  Kiwee
//
//  Created by NY on 2024/5/6.
//

import UIKit

private enum KWFontName: String {
    case regular = "NotoSansTC-Regular"
    case medium = "NotoSansTC-Medium"
}

extension UIFont {
    
    static func medium(size: CGFloat) -> UIFont? {
        return KWFont(.medium, size: size)
    }

    static func regular(size: CGFloat) -> UIFont? {
        return KWFont(.regular, size: size)
    }

    private static func KWFont(_ font: KWFontName, size: CGFloat) -> UIFont? {
        return UIFont(name: font.rawValue, size: size)
    }
    
}
