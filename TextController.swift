//
//  TextController.swift
//  justype
//
//  Created by Gibson Smiley on 4/1/16.
//  Copyright © 2016 Gibson Smiley. All rights reserved.
//

import UIKit

class TextController {
    
    enum TextStyle: String {
        case Normal = "AvenirNext-Medium"
        case Bold = "AvenirNext-Bold"
        case Italic = "AvenirNext-MediumItalic"
        case BoldItalic = "AvenirNext-BoldItalic"
    }
    
    static func avenirNext(style: String, size: CGFloat) -> UIFont {
    return UIFont(name: "AvenirNext-\(style)", size: size)!
        
        /* 
        Fonts
        AvenirNext-Bold
        AvenirNext-BoldItalic
        AvenirNext-DemiBold
        AvenirNext-DemiBoldItalic
        AvenirNext-Heavy
        AvenirNext-HeavyItalic
        AvenirNext-Italic
        AvenirNext-Medium
        AvenirNext-MediumItalic
        AvenirNext-Regular
        AvenirNext-UltraLight
        AvenirNext-UltraLightItalic
        */
    }
}