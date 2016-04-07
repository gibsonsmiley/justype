//
//  WriterViewController.swift
//  justype
//
//  Created by Gibson Smiley on 3/19/16.
//  Copyright © 2016 Gibson Smiley. All rights reserved.
//

import UIKit

class WriterViewController: UIViewController, UITextViewDelegate, PageViewControllerChild, NSTextStorageDelegate, UITextFieldDelegate {
    
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

        let seconds = Int64(0.0 * Double(NSEC_PER_SEC))
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, seconds), dispatch_get_main_queue()) {
            self.writerTextView.becomeFirstResponder()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardNotifications()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WriterViewController.reload), name: "userLoggedOut", object: nil)
        self.hideKeyboardWhenTappedAround()
//        darkModeTrue()

        toolbar.sizeToFit()

        writerTextView.keyboardDismissMode = .Interactive
        writerTextView.inputAccessoryView = toolbar
        writerTextView.delegate = self
        writerTextView.textStorage.delegate = self

        titleTextField.inputAccessoryView = toolbar
        titleTextField.delegate = self
        
        let hashtagFont = TextController.avenirNext("Bold", size: 24.0)
        tagButton.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.darkGrayColor(),NSFontAttributeName: hashtagFont], forState: .Normal)
        let listFont = TextController.avenirNext("Bold", size: 24.0)
        listButton.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.darkGrayColor(),NSFontAttributeName: listFont], forState: .Normal)
        let italicFont = TextController.avenirNext("DemiBoldItalic", size: 24.0)
        italicButton.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.darkGrayColor(),NSFontAttributeName: italicFont], forState: .Normal)
        let boldFont = TextController.avenirNext("Bold", size: 24.0)
        boldButton.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.darkGrayColor(),NSFontAttributeName: boldFont], forState: .Normal)
        let titleFont = TextController.avenirNext("Bold", size: 18.0)
        saveButton.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.darkGrayColor(), NSFontAttributeName: titleFont], forState: .Normal)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if UserController.sharedController.currentUser != nil {
            if NSUserDefaults.standardUserDefaults().boolForKey(kFirstTime) == false {
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: kFirstTime)
                NSUserDefaults.standardUserDefaults().synchronize()
                self.helper(welcomeLabel, text: welcomeLabel.text)
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        writerTextView.resignFirstResponder()
        
        if writerTextView.text.isEmpty != true {
            if let note = self.note {
                note.title = titleTextField.text
                note.text = self.writerTextView.attributedText.mutableCopy() as! NSMutableAttributedString
                NoteController.updateNote(note, completion: { (success, note) in
                    if success {
                        
                    }
                })
            } else {
                if let user = UserController.sharedController.currentUser.identifier {
                    NoteController.createNote(titleTextField.text, text:writerTextView.attributedText.mutableCopy() as! NSMutableAttributedString, timestamp: NSDate(), ownerID: user, completion: { (note) -> Void in
                        if let note = self.note {
                            note.text = self.writerTextView.attributedText.mutableCopy() as! NSMutableAttributedString
                        }
                    })
                }
            }
        }
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
    
    func updateWithNote(note: Note) {
        writerTextView.text = ""
        titleTextField.text = ""
        self.note = note
        self.titleTextField.text = note.title
        self.writerTextView.textStorage.appendAttributedString(note.text)
    }
        
    func helper(label: UILabel, text: String?) {
        label.text = text
        label.hidden = false
        self.helperLabel.fadeOut(completion: {
            (finished: Bool) -> Void in
            label.alpha = 1.0
            label.hidden = true
        })
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
        // This doesn't work because the status bar is technically on the PageViewController. And disabling it on the PageViewController will disable it for all pages.
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
        performSelector(#selector(setCursorToEnd), withObject: textView)
//        performSelector(#selector(setCursorToEnd), withObject: textView, afterDelay: 0.01)
        
        if textView.text.isEmpty {
            saveButton.title = "Hide"
        } else {
            saveButton.title = "Save"
        }
    }
    
    func setCursorToEnd(textView: UITextView) {
        textView.selectedRange = NSMakeRange(textView.endOfDocument.hashValue, 0)
    }
    
    func textViewDidChange(textView: UITextView) {
        if textView.text.isEmpty {
            saveButton.title = "Hide"
        } else {
            saveButton.title = "Save"
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.titleTextField {
            self.writerTextView.becomeFirstResponder()
        }
        return true
    }
    
    
    // MARK: - Toolbar Actions
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        if writerTextView.text.isEmpty {
            self.helper(self.helperLabel, text: "Swipe left to see your notes 👉")
            writerTextView.resignFirstResponder()
        } else {
            if let note = self.note {
                note.title = titleTextField.text
                note.text = self.writerTextView.attributedText.mutableCopy() as! NSMutableAttributedString
                NoteController.updateNote(note, completion: { (success, note) in
                    if success {
                        self.writerTextView.resignFirstResponder()
                        self.helper(self.helperLabel, text: "Note updated 👍")
                    }
                })
            } else {
                if let user = UserController.sharedController.currentUser.identifier {
                    NoteController.createNote(titleTextField.text, text:writerTextView.attributedText.mutableCopy() as! NSMutableAttributedString, timestamp: NSDate(), ownerID: user, completion: { (note) -> Void in
                        if let note = self.note {
                            note.text = self.writerTextView.attributedText.mutableCopy() as! NSMutableAttributedString
                        }
                        self.writerTextView.resignFirstResponder()
                        self.helper(self.helperLabel, text: "Note saved. It's over there 👉")
                    })
                }
            }
            writerTextView.text = ""
            titleTextField.text = ""
            self.note = nil
        }
    }
    
    func applyStyleToSelection(attributes: [String: AnyObject]) {
        let range = writerTextView.selectedRange
        print(range)
        writerTextView.textStorage.beginEditing()
        writerTextView.textStorage.setAttributes(attributes, range: range)
        writerTextView.textStorage.endEditing()
    }
    
    func properStyleForSelection(range: NSRange, style: TextController.TextStyle) -> [String: AnyObject] {
        let attributes = writerTextView.textStorage.attributesAtIndex(range.location, effectiveRange: nil)
        guard let currentFont = attributes[NSFontAttributeName] as? UIFont else {
            return [NSFontAttributeName: UIFont(name: style.rawValue, size: 17.0)!]
        }
        switch currentFont.fontName {
        case TextController.TextStyle.BoldItalic.rawValue:
            if style == TextController.TextStyle.Italic {
                return [NSFontAttributeName: UIFont(name: TextController.TextStyle.Bold.rawValue, size: 17.0)!]
            } else {
                return [NSFontAttributeName: UIFont(name: TextController.TextStyle.Italic.rawValue, size: 17.0)!]
            }
        case TextController.TextStyle.Bold.rawValue:
            if style == TextController.TextStyle.Bold {
                return [NSFontAttributeName: UIFont(name: TextController.TextStyle.Normal.rawValue, size: 17.0)!]
            } else {
                return [NSFontAttributeName: UIFont(name: TextController.TextStyle.BoldItalic.rawValue, size: 17.0)!]
            }
        case TextController.TextStyle.Italic.rawValue:
            if style == TextController.TextStyle.Italic {
                return [NSFontAttributeName: UIFont(name: TextController.TextStyle.Normal.rawValue, size: 17.0)!]
            } else {
                return [NSFontAttributeName: UIFont(name: TextController.TextStyle.BoldItalic.rawValue, size: 17.0)!]
            }
        default:
            return [NSFontAttributeName: UIFont(name: style.rawValue, size: 17.0)!]
        }
    }
    
    @IBAction func tagToolbarButtonTapped(sender: AnyObject) {
        if writerTextView.selectedTextRange?.empty == true {
            writerTextView.insertText("#")
        }
    }
    
    @IBAction func listToolbarButtonTapped(sender: AnyObject) {
        makeList()
    }
    
//    let attributesOfTappedText = writerTextView.textStorage.attributesAtIndex(range.location, effectiveRange: nil)
    let tappableText: NSAttributedString = NSAttributedString(string: "    ◎", attributes: ["   ◉":true])
    
    func textTapped(recognizer: UITapGestureRecognizer) {
        let textView: UITextView = (recognizer.view as! UITextView)
        let layoutManager: NSLayoutManager = textView.layoutManager
        var location: CGPoint = recognizer.locationInView(textView)
        location.x -= textView.textContainerInset.left
        location.y -= textView.textContainerInset.top
        let characterIndex: NSInteger
        characterIndex = layoutManager.characterIndexForPoint(location, inTextContainer: textView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        if characterIndex < textView.textStorage.length {
            let range: NSRange
            var value = textView.attributedText.attribute(" ◉", atIndex: characterIndex, effectiveRange: nil)
        }
        
    }
    
    func makeList() {
        if writerTextView.selectedTextRange?.empty == true {
            writerTextView.insertText(" ◎")
        }
    }

    @IBAction func boldToolbarButtonTapped(sender: AnyObject) {
        if titleTextField.isFirstResponder().boolValue == false {
            if writerTextView.selectedTextRange?.empty == true {
                self.helper(helperLabel, text: "You'll need to first select the \n text you'd like to format 🤓")
            } else {
                let selectedRange: NSRange = writerTextView.selectedRange
                
                let attributes = properStyleForSelection(selectedRange, style: TextController.TextStyle.Bold)
                applyStyleToSelection(attributes)
            }
        } else {
            self.helper(helperLabel, text: "You can't format the title 😁")
        }
    }
    
    @IBAction func italicToolbarButtonTapped(sender: AnyObject) {
        if titleTextField.isFirstResponder().boolValue == false {
            if writerTextView.selectedTextRange?.empty == true {
                self.helper(helperLabel, text: "You'll need to first select the \n text you'd like to format 🤓")
            } else {
                let selectedRange: NSRange = writerTextView.selectedRange
                let attributes = properStyleForSelection(selectedRange, style: TextController.TextStyle.Italic)
                applyStyleToSelection(attributes)
            }
        } else {
            self.helper(helperLabel, text: "You can't format the title 😁")
        }
        
    }
    
    
    // MARK: - Themes
    
    // Dark Mode
    
    /*
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
    } */
}
