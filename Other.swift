//
//  Other.swift
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
    
    func longFadeOut(duration: NSTimeInterval = 5.0, delay: NSTimeInterval = 0.0, completion: (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: .CurveEaseIn, animations: {
            self.alpha = 0.0
            }, completion: completion)
    }
    
    func longestFadeOut(duration: NSTimeInterval = 5.0, delay: NSTimeInterval = 0.0, completion: (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: .CurveEaseIn, animations: {
            self.alpha = 0.0
            }, completion: completion)
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UITextView {
    
    func scrollToBotom() {
        let range = NSMakeRange(text.characters.count - 1, 1);
        scrollRangeToVisible(range);
    }
    
}