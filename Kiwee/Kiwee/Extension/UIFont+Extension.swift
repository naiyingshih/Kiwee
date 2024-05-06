//
//  UIFont+Extension.swift
//  Kiwee
//
//  Created by NY on 2024/5/6.
//

import UIKit

private enum KWFontName: String {
    case regular = "Ping Fang TC"
}

extension UIFont {
    
//    static func bold(size: CGFloat) -> UIFont? {
//        var descriptor = UIFontDescriptor(name: KWFontName.regular.rawValue, size: size)
//        descriptor = descriptor.addingAttributes(
//            [.traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.bold]]
//        )
//        return UIFont(descriptor: descriptor, size: size)
//    }
//
//    static func medium(size: CGFloat) -> UIFont? {
//        var descriptor = UIFontDescriptor(name: KWFontName.regular.rawValue, size: size)
//        descriptor = descriptor.addingAttributes(
//            [.traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.medium]]
//        )
//        return UIFont(descriptor: descriptor, size: size)
//    }

    static func regular(size: CGFloat) -> UIFont? {
        return KWFont(.regular, size: size)
    }

    private static func KWFont(_ font: KWFontName, size: CGFloat) -> UIFont? {
        return UIFont(name: font.rawValue, size: size)
    }
    
}
