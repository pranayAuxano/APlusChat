//
//  Enum.swift
//  agsChat
//
//  Created by MAcBook on 28/11/22.
//

import Foundation
import UIKit

enum Colors
{
    case black, gray, lightGray, shadow, border, theme, themeDisable ,disable, themeBlue, disableButton, lightTheme, themeBlueBtn, longPressColor
    
    func returnColor() -> UIColor
    {
        switch self
        {
        case .black:
            return UIColor(red: 35.0/255.0, green: 35.0/255.0, blue: 35.0/255.0, alpha: 1.0)
        case .gray:
            return UIColor(red: 123.0/255.0, green: 123.0/255.0, blue: 123.0/255.0, alpha: 1.0)
        case .lightGray:
            return UIColor(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1.0)
        case .shadow:
            return UIColor(red: 35.0/255.0, green: 35.0/255.0, blue: 35.0/255.0, alpha: 0.2)
        case .border:
            return UIColor(red: 211.0/255.0, green: 211.0/255.0, blue: 211.0/255.0, alpha: 1.0)
        case .theme:
            return UIColor(red: 139.0/255.0, green:0.0/255.0, blue:0.0/255.0, alpha:1.0)
        case .themeDisable:
            return UIColor(red: 189.0/255.0, green:115.0/255.0, blue:116.0/255.0, alpha:1.0)
        case .disable:
            return UIColor(red: 221.0/255.0, green:221.0/255.0, blue:221.0/255.0, alpha:0.5)
        case .disableButton:
            return UIColor(red: 149.0/255.0, green:149.0/255.0, blue:149.0/255.0, alpha:1)
        case .themeBlue:
            return UIColor(red: 0.0/255.0, green:174/255.0, blue:240/255.0, alpha:1)
        case .lightTheme:
            return UIColor(red: 255.0/255.0, green: 33.0/255.0, blue: 33.0/255.0, alpha:1.0)
        case .themeBlueBtn:
            return UIColor(red: 15.0/255.0, green: 101.0/255.0, blue: 158.0/255.0, alpha:1.0)
        case .longPressColor:
            return UIColor(hexString: "#68BBE3")
        }
    }
}

public enum ThemeColor
{
    case red, blue, yellow
}
