//
//  SettingsTableViewController.swift
//  justype
//
//  Created by Gibson Smiley on 3/22/16.
//  Copyright © 2016 Gibson Smiley. All rights reserved.
//

import UIKit
import SafariServices

class SettingsTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var darkModeSwitch: UIView!
    @IBOutlet var fontPickerView: UIPickerView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var colorModeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var accountInfoButton: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var doneNavBarButton: UIBarButtonItem!
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var contactButton: UIButton!
    @IBOutlet weak var donateButton: UIButton!
    @IBOutlet weak var copyrightTextField: UILabel!
    @IBOutlet weak var creditsTextField: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var colorModeLabel: UILabel!
    @IBOutlet weak var fontPickerTextField: UITextField!
    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet weak var doneToolbarButton: UIBarButtonItem!
    @IBOutlet weak var fontSizeLabel: UILabel!
    
    // MARK: - Properties
    
    var colorMode: Int! {
        return NSUserDefaults.standardUserDefaults().integerForKey("colorMode")
    }
    
    var usersFont: String! {
        if NSUserDefaults.standardUserDefaults().stringForKey("fontStyle") == nil {
            return "Avenir Next"
        } else {
            return NSUserDefaults.standardUserDefaults().stringForKey("fontStyle")
        }
    }
    
    var usersFontSize: Float! {
        if NSUserDefaults.standardUserDefaults().floatForKey("fontSize") == 0.0 {
            return 17.0
        } else {
            return NSUserDefaults.standardUserDefaults().floatForKey("fontSize")
        }
    }
    
    var pickerData: [String] = ["Current Font","Avenir Next", "Arial", "Bradley Hand", "Courier", "Futura", "Gill Sans", "Helvetica", "Noteworthy", "Times New Roman"]
    let titleFont : UIFont = UIFont(name: "Avenir-Medium", size: 22.0)!
    
    // MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SettingsTableViewController.localNotificationFired), name: "AccountActionSheet", object: nil)
        
        fontManager()
        fontSizeManager()
        segmentedControlVisual()
        changeColorMode()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("Memory warning on SettingsTableView")
    }
    
    // MARK: - Methods
    
    func segmentedControlVisual() {
        if self.colorMode == 0 {
            self.colorModeSegmentedControl.selectedSegmentIndex = 0
        } else if self.colorMode == 1 {
            self.colorModeSegmentedControl.selectedSegmentIndex = 1
        } else if self.colorMode == 2 {
            self.colorModeSegmentedControl.selectedSegmentIndex = 2
        }
    }
    
    func localNotificationFired() {
        let alertController = UIAlertController(title: "Account: \(UserController.sharedController.currentUser.email)", message: nil, preferredStyle: .ActionSheet)
        
        let deleteAction = UIAlertAction(title: "Log Out", style: .Destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            UserController.logoutUser()
            self.dismissViewControllerAnimated(true, completion: nil)
            NSNotificationCenter.defaultCenter().postNotificationName("userLoggedOut", object: nil, userInfo: nil)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Actions
    
    @IBAction func DoneButtonTapped(sender: AnyObject) {
        if fontPickerTextField.isFirstResponder() {
            // Do nothing
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func accountButtonTapped(sender: AnyObject) {
        if fontPickerTextField.isFirstResponder() {
            // Do nothing
        } else {
            
            let notifcation = UILocalNotification()
            UIApplication.sharedApplication().scheduleLocalNotification(notifcation)
        }
    }
    
    @IBAction func doneToolbarButtonTapped(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setValue(fontPickerTextField.text, forKey: "fontStyle")
        colorModeSegmentedControl.enabled = true
        fontPickerTextField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        colorModeSegmentedControl.enabled = false
    }
    
    @IBAction func segmentedControlValueChanged(sender: AnyObject) {
        if fontPickerTextField.isFirstResponder() {
            // Do nothing
        } else {
            
            
            self.tableView.reloadData()
            self.reloadInputViews()
            
            if colorModeSegmentedControl.selectedSegmentIndex == 0 { // yellow
                NSUserDefaults.standardUserDefaults().setInteger(1, forKey: "colorMode")
                changeColorMode()
            } else if colorModeSegmentedControl.selectedSegmentIndex == 1 { // white
                NSUserDefaults.standardUserDefaults().setInteger(2, forKey: "colorMode")
                changeColorMode()
            } else if colorModeSegmentedControl.selectedSegmentIndex == 2 { // black
                NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "colorMode")
                changeColorMode()
            }
        }
    }
    
    @IBAction func contactButtonTapped(sender: AnyObject) {
        if fontPickerTextField.isFirstResponder() {
            // Do nothing
        } else {
            
            if let url = NSURL(string: "http://gibsonsmiley.com") {
                let viewController = SFSafariViewController(URL: url)
                presentViewController(viewController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func donateButtonTapped(sender: AnyObject) {
        if fontPickerTextField.isFirstResponder() {
            // Do nothing
        } else {
            if let url = NSURL(string: "https://venmo.com/Gibson") {
                let viewController = SFSafariViewController(URL: url)
                presentViewController(viewController, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Font Management
    
    func fontManager() {
        fontPickerTextField.inputView = fontPickerView
        fontPickerTextField.inputAccessoryView = toolbar
        fontPickerTextField.tintColor = UIColor.clearColor()
        fontPickerTextField.font = TextController.font(usersFont, size: usersFontSize)
        fontPickerTextField.text = usersFont
    }
    
    func fontSizeManager() {
        fontSizeLabel.text = "\(Int(usersFontSize)) pt"
    }
    
    // MARK: - Picker View Data Source
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        colorModeSegmentedControl.enabled = false
        if row != 0 {
            fontPickerTextField.font = TextController.font(pickerData[row], size: usersFontSize)
            self.fontPickerTextField.text = pickerData[row]
        } else {
            // Do nothing
        }
    }
    
    
    // MARK: - Color Mode
    
    func changeColorMode() {
        if self.colorMode == 0 {
            yellowColorMode()
            self.navigationController?.reloadInputViews()
        } else if self.colorMode == 1 {
            whiteColorMode()
            self.navigationController?.reloadInputViews()
        } else if self.colorMode == 2 {
            blackColorMode()
            self.navigationController?.reloadInputViews()
        }
    }
    
    func yellowColorMode() {
        // View
        view.backgroundColor = UIColor.notesYellow()
        navBar.barTintColor = UIColor.notesYellow()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.blackColor(), NSFontAttributeName: titleFont]
        accountInfoButton.backgroundColor = UIColor.notesYellow()
        accountInfoButton.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
        topView.backgroundColor = UIColor.notesYellow()
        doneNavBarButton.tintColor = UIColor.darkGrayColor()
        tableView.backgroundColor = UIColor.notesYellow()
        doneToolbarButton.tintColor = UIColor.blackColor()

        
        // Settings
        colorModeLabel.textColor = UIColor.blackColor()
        rateButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        contactButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        donateButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        copyrightTextField.textColor = UIColor.blackColor()
        creditsTextField.textColor = UIColor.blackColor()
        iconImageView.image = UIImage(named: "icon")
        fontPickerView.backgroundColor = UIColor.notesYellow()
        toolbar.tintColor = UIColor.notesYellow()
        
        // Misc
        colorModeSegmentedControl.tintColor = UIColor.blackColor()
        
    }
    
    func whiteColorMode() {
        // View
        view.backgroundColor = UIColor.whiteColor()
        navBar.barTintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.blackColor(), NSFontAttributeName: titleFont]
        accountInfoButton.backgroundColor = UIColor.whiteColor()
        accountInfoButton.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
        topView.backgroundColor = UIColor.whiteColor()
        tableView.backgroundColor = UIColor.whiteColor()
        doneNavBarButton.tintColor = UIColor.darkGrayColor()
        
        // Settings
        colorModeLabel.textColor = UIColor.blackColor()
        rateButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        contactButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        donateButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        copyrightTextField.textColor = UIColor.blackColor()
        creditsTextField.textColor = UIColor.blackColor()
        iconImageView.image = UIImage(named: "icon")
        fontPickerView.backgroundColor = UIColor.whiteColor()
        toolbar.tintColor = UIColor.whiteColor()
        doneToolbarButton.tintColor = UIColor.blackColor()
        
        // Misc
        colorModeSegmentedControl.tintColor = UIColor.blackColor()
    }
    
    func blackColorMode() {
        // View
        view.backgroundColor = UIColor.offBlackColor()
        navBar.barTintColor = UIColor.offBlackColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName: titleFont]
        accountInfoButton.backgroundColor = UIColor.offBlackColor()
        accountInfoButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        topView.backgroundColor = UIColor.offBlackColor()
        doneNavBarButton.tintColor = UIColor.lightGrayColor()
        tableView.backgroundColor = UIColor.offBlackColor()
        
        // Settings
        colorModeLabel.textColor = UIColor.whiteColor()
        rateButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        contactButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        donateButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        copyrightTextField.textColor = UIColor.whiteColor()
        creditsTextField.textColor = UIColor.whiteColor()
        iconImageView.image = UIImage(named: "yellowIcon")
        fontPickerView.backgroundColor = UIColor.offBlackColor()
        toolbar.tintColor = UIColor.offBlackColor()
        doneToolbarButton.tintColor = UIColor.whiteColor()
        
        // Misc
        colorModeSegmentedControl.tintColor = UIColor.whiteColor()
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
        if colorMode == 0 {
            cell.textLabel?.textColor = UIColor.blackColor()
        } else if colorMode == 1 {
            cell.textLabel?.textColor = UIColor.blackColor()
        } else if colorMode == 2 {
            cell.textLabel?.textColor = UIColor.whiteColor()
        }
    }
}
