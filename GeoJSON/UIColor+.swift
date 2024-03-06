//
//  UIColor+.swift
//  GeoJSON
//
//  Created by Johnnie Walker on 03.03.2024.
//

import UIKit

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1) {
        var hex = hex
        if hex.hasPrefix("#") {
            hex.remove(at: hex.startIndex)
        }
        let scanner = Scanner(string: hex)
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        self.init(
            red: CGFloat((color & 0xFF0000) >> 16) / 255,
            green: CGFloat((color & 0x00FF00) >> 8) / 255,
            blue: CGFloat(color & 0x0000FF) / 255,
            alpha: alpha
        )
    }
}
