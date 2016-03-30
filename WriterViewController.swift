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
    @IBOutlet weak var successLabel: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var tagButton: UIBarButtonItem!
    @IBOutlet weak var listButton: UIBarButtonItem!
    @IBOutlet weak var boldButton: UIBarButtonItem!
    @IBOutlet weak var italicButton: UIBarButtonItem!
    @IBOutlet weak var titleTextField: UITextField!
    
    
    var pageView: UIPageViewController?
    var note: Note?
    static let sharedInstance = WriterViewController()
    
    
    // MARK: - View
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        successLabel.hidden = true
        
        // Something is happening with the page view controller after the writerview is initialy loaded, so that once returning to the writer view from the list view something in the page controller is "catching" the first responder, therefor stopping it. This hacky fix pauses the firstresponder long enough to avoid being "caught." firstresponder will be caught at 0.25.
        // Possible fix putting this code or a seperate function holding the becomefirstresponder and putting it in either writerview or pageview or both.
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
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        writerTextView.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Actions
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        if writerTextView.text.isEmpty {
            successLabel.hidden = false
            successLabel.text = "Swipe left to see your notes 👉"
            writerTextView.resignFirstResponder()
        } else {
            if let note = self.note {
                note.text = self.writerTextView.attributedText.mutableCopy() as! NSMutableAttributedString
                NoteController.updateNote(note, completion: { (success, note) in
                    if success {
                        self.writerTextView.resignFirstResponder()
                        self.successLabel.hidden = false
                        self.successLabel.text = "Note updated 👍"
                    }
                })
            } else {
                writerTextView.resignFirstResponder()
                successLabel.hidden = false
                successLabel.text = "Note saved. It's over there 👉"
                if let user = UserController.currentUser.identifier {
                    NoteController.createNote(titleTextField.text, text:writerTextView.attributedText.mutableCopy() as! NSMutableAttributedString, ownerID: user, completion: { (note) -> Void in
                        if let note = self.note {
                            note.text = self.writerTextView.attributedText.mutableCopy() as! NSMutableAttributedString
                        }
                    })
                }
            }
            writerTextView.text = ""
            titleTextField.text = ""
        }
    }
    
    func updateWithNote(note: Note) {
        self.note = note
        self.titleTextField.text = note.title
        self.writerTextView.textStorage.appendAttributedString(note.text)
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
    
//    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
//        if text == "/n" {
//            if range.location == textView.text.characters.count {
//                let updatedText = textView.text.stringByAppendingString("•")
//                textView.text = updatedText
//            } else {
//                let beginning = textView.beginningOfDocument
//                let start = textView.positionFromPosition(beginning, offset: range.location)
//                let end = textView.positionFromPosition(start!, offset: range.length)
//                let textRange = textView.textRangeFromPosition(start!, toPosition: end!)
//
//                textView.replaceRange(textRange!, withText: "•")
//                let cursor = NSMakeRange(range.location + "•".characters.count, 0)
//                textView.selectedRange = cursor
//            }
//            return false
//        }
//        return true
//    }
    
    
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
        writerTextView.insertText("•")
    }

    @IBAction func boldToolbarButtonTapped(sender: AnyObject) {
        applyStyleToSelection("AvenirNext-Bold")
        
//        if boldButton.title == "UnBold" {
//            boldButton.title = "Bold"
//        } else {
//            boldButton.title = "UnBold"
//        }
    }
    
    @IBAction func italicToolbarButtonTapped(sender: AnyObject) {
        applyStyleToSelection("AvenirNext-MediumItalic")
        
//        if italicButton.title == "UnItalic" {
//            italicButton.title = "Italic"
//        } else {
//            italicButton.title = "UnItalic"
//        }
    }
    
    // MARK: - Themes
    
    // Dark Mode
    
    func darkModeTrue() {
        if AppearanceController.darkMode == true {
            writerTextView.backgroundColor = UIColor.offBlackColor()
            view.backgroundColor = UIColor.offBlackColor()
            toolbar.tintColor = UIColor.whiteColor()
            writerTextView.textColor = UIColor.whiteColor()
            successLabel.textColor = UIColor.whiteColor()
            toolbar.barTintColor = UIColor.offBlackColor()
            writerTextView.keyboardAppearance = UIKeyboardAppearance.Dark
            UITextView.appearance().tintColor = UIColor.whiteColor()

        }
    }
    
    func textStorage(textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        if editedMask == NSTextStorageEditActions.EditedAttributes {
            //writerTextView.textStorage.attri
        }
    }
}
