//
//  SegueToNote.swift
//  justype
//
//  Created by Gibson Smiley on 3/23/16.
//  Copyright © 2016 Gibson Smiley. All rights reserved.
//

import UIKit

class SegueToNote: UIStoryboardSegue {

    override func perform() {
        let sender = self.sourceViewController.view as UIView
        let receiver = self.destinationViewController.view as UIView
        
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let screenHeight = UIScreen.mainScreen().bounds.size.height
        
        receiver.frame = CGRectMake(0.0, screenHeight, screenWidth, screenHeight)
        
        let window = UIApplication.sharedApplication().keyWindow
        window?.insertSubview(receiver, aboveSubview: sender)
        
        UIView.animateWithDuration(0.4, animations: {
            sender.frame = CGRectOffset(sender.frame, +screenWidth, 0.0)
            receiver.frame = CGRectOffset(receiver.frame, +screenWidth, 0.0)
            }) { (finished) in
                self.sourceViewController.presentViewController(self.destinationViewController as UIViewController, animated: false, completion: nil)
        }
    }
}
