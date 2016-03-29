//
//  AppearanceController.swift
//  justype
//
//  Created by Gibson Smiley on 3/22/16.
//  Copyright © 2016 Gibson Smiley. All rights reserved.
//

import Foundation
import UIKit

class AppearanceController {
    
    static var darkMode: Bool = false
   
    static func initializeAppearance() {
        UITextView.appearance().tintColor = UIColor.blackColor()
        UIButton.appearance().tintColor = UIColor.darkGrayColor()
        let titleFont : UIFont = UIFont(name: "Avenir-Medium", size: 17.0)!
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.darkGrayColor(), NSFontAttributeName: titleFont], forState: .Normal)
        
        UIBarButtonItem.appearance().tintColor = UIColor.darkGrayColor()
    }

    static func changeColorMode() {
        if self.darkMode == true {
            UIView.appearance().backgroundColor = UIColor.offBlackColor()
            UINavigationBar.appearance().tintColor = UIColor.offBlackColor()
            UITextView.appearance().backgroundColor = UIColor.offBlackColor()
            UITableView.appearance().backgroundColor = UIColor.offBlackColor()
            UIKeyboardAppearance.Dark
        }
    }
}
