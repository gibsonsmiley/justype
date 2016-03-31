//
//  Animation.swift
//  justype
//
//  Created by Gibson Smiley on 3/30/16.
//  Copyright © 2016 Gibson Smiley. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func fadeOut(duration: NSTimeInterval = 2.0, delay: NSTimeInterval = 0.0, completion: (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: .CurveEaseIn, animations: { 
            self.alpha = 0.0
            }, completion: completion)
    }
}