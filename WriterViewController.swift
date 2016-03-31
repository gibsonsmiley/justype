//
//  WriterViewController.swift
//  justype
//
//  Created by Gibson Smiley on 3/19/16.
//  Copyright © 2016 Gibson Smiley. All rights reserved.
//

import UIKit

class WriterViewController: UIViewController, UITextViewDelegate, PageViewControllerChild, NSTextStorageDelegate {
    
    @IBOutlet weak var writerTextView: UITextView!
    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var tagButton: UIBarButtonItem!
    @IBOutlet weak var listButton: UIBarButtonItem!
    @IBOutlet weak var boldButton: UIBarButtonItem!
    @IBOutlet weak var italicButton: UIBarButtonItem!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var helperLabel: UILabel!
    @IBOutlet weak var welcomeLabel: UILabel!
    
    
    var pageView: UIPageViewController?
    var note: Note?
    static let sharedInstance = WriterViewController()
    var firstTime: Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(kFirstTime)
    }
    private let kFirstTime = "firstTime"
    
    
    // MARK: - View
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        if NSUserDefaults.standardUserDefaults().boolForKey(kFirstTime) == false {
            firstTimer()
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: kFirstTime)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        let seconds = Int64(0.0 * Double(NSEC_PER_SEC))
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, seconds), dispatch_get_main_queue()) {
            self.writerTextView.becomeFirstResponder()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toolbar.sizeToFit()
        writerTextView.inputAccessoryView = toolbar
        titleTextField.inputAccessoryView = toolbar
        darkModeTrue()
        setupKeyboardNotifications()
        writerTextView.textStorage.delegate = self
        let titleFont : UIFont = UIFont(name: "Avenir-Black", size: 17.0)!
        saveButton.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.darkGrayColor(), NSFontAttributeName: titleFont], forState: .Normal)
        self.hideKeyboardWhenTappedAround()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WriterViewController.reload), name: "userLoggedOut", object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        writerTextView.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("Memory warning on WriterView")
    }
    
    
    // MARK: - Actions
    
    func reload() {
        writerTextView.text = ""
        titleTextField.text = ""
    }
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        if writerTextView.text.isEmpty {
            self.helperLabel.text = "Swipe left to see your notes 👉"
            self.helperLabel.hidden = false
            self.helperLabel.fadeOut(completion: {
                (finished: Bool) -> Void in
                self.helperLabel.alpha = 1.0
                self.helperLabel.hidden = true
            })
            writerTextView.resignFirstResponder()
        } else {
            if let note = self.note {
                note.title = titleTextField.text
                note.text = self.writerTextView.attributedText.mutableCopy() as! NSMutableAttributedString
                NoteController.updateNote(note, completion: { (success, note) in
                    if success {
                        self.writerTextView.resignFirstResponder()
                        self.helperLabel.text = "Note updated 👍"
                        self.helperLabel.hidden = false
                        self.helperLabel.fadeOut(completion: {
                            (finished: Bool) -> Void in
                            self.helperLabel.alpha = 1.0
                            self.helperLabel.hidden = true
                        })
                    }
                })
            } else {
                writerTextView.resignFirstResponder()
                self.helperLabel.text = "Note saved. It's over there 👉"
                self.helperLabel.hidden = false
                self.helperLabel.fadeOut(completion: {
                    (finished: Bool) -> Void in
                    self.helperLabel.alpha = 1.0
                    self.helperLabel.hidden = true
                })
                if let user = UserController.sharedController.currentUser.identifier {
                    NoteController.createNote(titleTextField.text, text:writerTextView.attributedText.mutableCopy() as! NSMutableAttributedString, ownerID: user, completion: { (note) -> Void in
                        if let note = self.note {
                            note.text = self.writerTextView.attributedText.mutableCopy() as! NSMutableAttributedString
                        }
                    })
                }
            }
            writerTextView.text = ""
            titleTextField.text = ""
            self.note = nil
        }
    }
    
    func updateWithNote(note: Note) {
        writerTextView.text = ""
        titleTextField.text = ""
        self.note = note
        self.titleTextField.text = note.title
        self.writerTextView.textStorage.appendAttributedString(note.text)
    }
    
    func firstTimer() {
        self.welcomeLabel.hidden = false
        self.welcomeLabel.longestFadeOut(completion : {
            (finished: Bool) -> Void in
            self.welcomeLabel.alpha = 1.0
            self.welcomeLabel.hidden = true
        })
    }
    
    
    // MARK: - Keyboard
    
    func setupKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WriterViewController.keyboardWasShown(_:)), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WriterViewController.keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification) {
        let info = notification.userInfo
        let infoNSValue = info! [UIKeyboardFrameBeginUserInfoKey] as! NSValue
        let kbSize = infoNSValue.CGRectValue().size
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0)
        writerTextView.contentInset = contentInsets
        writerTextView.scrollIndicatorInsets = contentInsets
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        let contentInsets = UIEdgeInsetsZero
        writerTextView.contentInset = contentInsets
        writerTextView.scrollIndicatorInsets = contentInsets
    }
    
    
    // MARK: - Text View
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text.isEmpty {
            saveButton.title = "Hide"
        } else {
            saveButton.title = "Save"
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        if textView.text.isEmpty {
            saveButton.title = "Hide"
        } else {
            saveButton.title = "Save"
        }
    }
    
    
    // MARK: - Toolbar Actions
    
    func applyStyleToSelection(style: String) {
        let range = writerTextView.selectedRange
        let styledFont = UIFont(name: style, size: 17.0)!
        
        writerTextView.textStorage.beginEditing()
        let dict = [NSFontAttributeName: styledFont]
        writerTextView.textStorage.setAttributes(dict, range: range)
        writerTextView.textStorage.endEditing()
    }
    
    @IBAction func tagToolbarButtonTapped(sender: AnyObject) {
        writerTextView.insertText("#")
    }
    
    @IBAction func listToolbarButtonTapped(sender: AnyObject) {
        writerTextView.insertText("   • ")
    }

    @IBAction func boldToolbarButtonTapped(sender: AnyObject) {
        applyStyleToSelection("AvenirNext-Bold")
        
        if writerTextView.selectedTextRange == nil {
            self.helperLabel.text = "You'll need to first select the \n text you'd like to format 🤓"
            self.helperLabel.hidden = false
            self.helperLabel.fadeOut(completion: {
                
                
                (finished: Bool) -> Void in
                self.helperLabel.alpha = 1.0
                self.helperLabel.hidden = true
            })
        }
    }
    
    @IBAction func italicToolbarButtonTapped(sender: AnyObject) {
        applyStyleToSelection("AvenirNext-MediumItalic")
    }
    
    // MARK: - Themes
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // Dark Mode
    
    func themeNotification() {
       
    }
    
    func darkModeTrue() {
        if AppearanceController.darkMode == true {
            writerTextView.backgroundColor = UIColor.offBlackColor()
            view.backgroundColor = UIColor.offBlackColor()
            toolbar.tintColor = UIColor.whiteColor()
            writerTextView.textColor = UIColor.whiteColor()
            toolbar.barTintColor = UIColor.offBlackColor()
            titleTextField.keyboardAppearance = UIKeyboardAppearance.Dark
            writerTextView.keyboardAppearance = UIKeyboardAppearance.Dark
            UITextView.appearance().tintColor = UIColor.whiteColor()
            titleTextField.textColor = UIColor.whiteColor()
            helperLabel.textColor = UIColor.whiteColor()

        }
    }
}
