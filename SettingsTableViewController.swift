//
//  SettingsTableViewController.swift
//  justype
//
//  Created by Gibson Smiley on 3/22/16.
//  Copyright © 2016 Gibson Smiley. All rights reserved.
//

import UIKit
import SafariServices

class SettingsTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let titleFont : UIFont = UIFont(name: "Avenir-Medium", size: 22.0)!
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.blackColor(), NSFontAttributeName: titleFont]
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SettingsTableViewController.localNotificationFired), name: "AccountActionSheet", object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Actions
    
    @IBAction func DoneButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func accountButtonTapped(sender: AnyObject) {
        let notifcation = UILocalNotification()
        UIApplication.sharedApplication().scheduleLocalNotification(notifcation)
    }
    
    func localNotificationFired() {
        let alertController = UIAlertController(title: "Account: \(UserController.currentUser.email)", message: nil, preferredStyle: .ActionSheet)
        
        let deleteAction = UIAlertAction(title: "Log Out", style: .Destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            UserController.logoutUser()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)

        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
