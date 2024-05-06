//
//  UIColor+Extension.swift
//  Kiwee
//
//  Created by NY on 2024/4/11.
//

import UIKit
import SwiftUI

struct KWColor {
    static let background = UIColor.hexStringToUIColor(hex: "F8F7F2")
    static let cardBackground = UIColor.hexStringToUIColor(hex: "F4F4F4")
    static let darkB = UIColor.hexStringToUIColor(hex: "004358")
    static let darkG = UIColor.hexStringToUIColor(hex: "1F8A70")
    static let lightY = UIColor.hexStringToUIColor(hex: "FFD500")
    static let lightG = UIColor.hexStringToUIColor(hex: "BEDB39")
    static let lightO = UIColor.hexStringToUIColor(hex: "FB8500")
}

extension UIColor {

    static func hexStringToUIColor(hex: String) -> UIColor {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if (cString.count) != 6 {
            return .gray
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let alpha, red, green, blue: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (alpha, red, green, blue) = (255, 0, 0, 0)
        }

        self.init(.sRGB, red: Double(red) / 255, green: Double(green) / 255, blue:  Double(blue) / 255, opacity: Double(alpha) / 255)
    }
}
