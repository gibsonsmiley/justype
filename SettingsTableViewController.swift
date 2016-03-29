//
//  SettingsTableViewController.swift
//  justype
//
//  Created by Gibson Smiley on 3/22/16.
//  Copyright © 2016 Gibson Smiley. All rights reserved.
//

import UIKit
import SafariServices

class SettingsTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var fontPickerView: UIPickerView!
    @IBOutlet var fontSizePickerView: UIPickerView!
    
    var pickerData: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        darkModeTrue()
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
    @IBAction func darkModeSwitched(sender: UISwitch) {
        if true {
            AppearanceController.darkMode = true
        } else if false {
            AppearanceController.darkMode = false
        }
    }
    
    @IBAction func fontPickerTapped(sender: AnyObject) {
    }
    
    @IBAction func fontSizePickerTapped(sender: AnyObject) {
    }
    
    @IBAction func contactButtonTapped(sender: AnyObject) {
        if let url = NSURL(string: "http://gibsonsmiley.com") {
        let viewController = SFSafariViewController(URL: url)
        presentViewController(viewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func donateButtonTapped(sender: AnyObject) {
        if let url = NSURL(string: "https://venmo.com/Gibson") {
            let viewController = SFSafariViewController(URL: url)
            presentViewController(viewController, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - Picker View Data Source
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return pickerData.count
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    // MARK: - Themes
    
    // Dark Mode
    
    func darkModeTrue() {
        if AppearanceController.darkMode == true {
            tableView.backgroundColor = UIColor.offBlackColor()
            tableView.tableHeaderView?.backgroundColor = UIColor.offBlackColor()
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if AppearanceController.darkMode == true {
            cell.backgroundColor = UIColor.clearColor()
        }
    }
}
