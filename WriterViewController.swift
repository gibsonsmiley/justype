//
//  WriterViewController.swift
//  justype
//
//  Created by Gibson Smiley on 3/19/16.
//  Copyright © 2016 Gibson Smiley. All rights reserved.
//

import UIKit

class WriterViewController: UIViewController, UITextViewDelegate, PageViewControllerChild, NSTextStorageDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    // MARK: - Outlets
    
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
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    
    // MARK: - Properties
    
    var pageView: UIPageViewController?
    var note: Note?
    static let sharedInstance = WriterViewController()
    var firstTime: Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(kFirstTime)
    }
    private let kFirstTime = "firstTime"
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
        
        toolbar.sizeToFit()
        
        writerTextView.keyboardDismissMode = .Interactive
        writerTextView.inputAccessoryView = toolbar
        writerTextView.delegate = self
        writerTextView.textStorage.delegate = self
        writerTextView.font = TextController.font(usersFont, size: usersFontSize)
        
        titleTextField.inputAccessoryView = toolbar
        titleTextField.delegate = self
        
        let hashtagFont = TextController.avenirNext("Bold", size: 24.0)
        tagButton.setTitleTextAttributes([NSFontAttributeName: hashtagFont], forState: .Normal)
        let listFont = TextController.avenirNext("Bold", size: 24.0)
        listButton.setTitleTextAttributes([NSFontAttributeName: listFont], forState: .Normal)
        let italicFont = TextController.avenirNext("DemiBoldItalic", size: 24.0)
        italicButton.setTitleTextAttributes([NSFontAttributeName: italicFont], forState: .Normal)
        let boldFont = TextController.avenirNext("Bold", size: 24.0)
        boldButton.setTitleTextAttributes([NSFontAttributeName: boldFont], forState: .Normal)
        let titleFont = TextController.avenirNext("Bold", size: 18.0)
        saveButton.setTitleTextAttributes([NSFontAttributeName: titleFont], forState: .Normal)
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
        
        changeColorMode()
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
        
        if textView.text.isEmpty {
            saveButton.title = "Hide"
        } else {
            saveButton.title = "Save"
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if self.note != nil {
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
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if writerTextView.text.isEmpty {
            let normalText = NSMutableAttributedString(string: "", attributes: [NSFontAttributeName: TextController.font(usersFont, size: usersFontSize)])
            writerTextView.textStorage.setAttributedString(normalText)
        }
        return true
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
                        self.helper(self.helperLabel, text: "Note updated 👍")
                    }
                })
            } else {
                if let user = UserController.sharedController.currentUser.identifier {
                    NoteController.createNote(titleTextField.text, text:writerTextView.attributedText.mutableCopy() as! NSMutableAttributedString, timestamp: NSDate(), ownerID: user, completion: { (note) -> Void in
                        if let note = self.note {
                            note.text = self.writerTextView.attributedText.mutableCopy() as! NSMutableAttributedString
                        }
                        self.helper(self.helperLabel, text: "Note saved. It's over there 👉")
                    })
                }
            }
            writerTextView.text = ""
            let length = writerTextView.text.characters.count
            writerTextView.textStorage.addAttributes([NSFontAttributeName: TextController.font(usersFont, size: usersFontSize)], range: NSMakeRange(0, length))
            let normalText = NSMutableAttributedString(string: " ", attributes: [NSFontAttributeName: TextController.font(usersFont, size: usersFontSize)])
            writerTextView.textStorage.setAttributedString(normalText)
            writerTextView.selectedRange = NSMakeRange(0, 0)
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
        writerTextView.selectedRange = NSMakeRange(range.location + range.length + 1, 0)
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
    
    let unfilledBullet = NSMutableAttributedString(string: "◎", attributes: [NSFontAttributeName: TextController.avenirNext("Regular", size: 22.0)]) // NSForegroundcolor-something?
    let filledBullet = NSMutableAttributedString(string: "◉", attributes: [NSFontAttributeName: TextController.avenirNext("Regular", size: 22.0)])
    let normalText = NSMutableAttributedString(string: " ", attributes: [NSFontAttributeName: TextController.avenirNext("Medium", size: 17.0)])
    
    @IBAction func textTapped(recognizer: UITapGestureRecognizer) {
        let textView: UITextView = (recognizer.view as! UITextView)
        let layoutManager: NSLayoutManager = textView.layoutManager
        var location: CGPoint = recognizer.locationInView(textView)
        location.x -= textView.textContainerInset.left
        location.y -= textView.textContainerInset.top
        
        let characterIndex: Int
        characterIndex = layoutManager.characterIndexForPoint(location, inTextContainer: textView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        if characterIndex < textView.textStorage.length {
            let range = NSMakeRange(characterIndex, 1)
            let currentCursorPosition = textView.selectedRange
            let characterAtIndex = textView.textStorage.attributedSubstringFromRange(range).string
            
            if characterAtIndex == (unfilledBullet.string) {
                textView.textStorage.replaceCharactersInRange(range, withString: "\(filledBullet.string)")
                textView.textStorage.addAttributes([NSFontAttributeName: TextController.avenirNext("Regular", size: 22.0)], range: range)
                textView.selectedRange = currentCursorPosition
            } else if characterAtIndex == (filledBullet.string) {
                textView.textStorage.replaceCharactersInRange(range, withString: "\(unfilledBullet.string)")
                textView.textStorage.addAttributes([NSFontAttributeName: TextController.avenirNext("Regular", size: 22.0)], range: range)
                textView.selectedRange = currentCursorPosition
            }
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func makeList() {
        if writerTextView.selectedTextRange?.empty == true {
            let range = writerTextView.selectedRange
            writerTextView.textStorage.insertAttributedString(unfilledBullet, atIndex: range.location)
            writerTextView.textStorage.insertAttributedString(normalText, atIndex: range.location + 1)
            writerTextView.selectedRange = NSMakeRange(range.location + 2, 0)
            writerTextView.textStorage.addAttributes([NSFontAttributeName: TextController.avenirNext("Medium", size: 17.0)], range: NSMakeRange(range.location + 2, 0))
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
    
    
    // MARK: - Color Mode
    
    func changeColorMode() {
        if self.colorMode == 0 {
            yellowColorMode()
        } else if self.colorMode == 1 {
            whiteColorMode()
        } else if self.colorMode == 2 {
            blackColorMode()
        }
    }
    
    func yellowColorMode() {
        // View
        writerTextView.backgroundColor = UIColor.notesYellow()
        view.backgroundColor = UIColor.notesYellow()
        writerTextView.keyboardAppearance = UIKeyboardAppearance.Dark
        writerTextView.textColor = UIColor.blackColor()
        
        // Toolbar
        toolbar.barStyle = .Black
        saveButton.tintColor = UIColor.whiteColor()
        tagButton.tintColor = UIColor.whiteColor()
        listButton.tintColor = UIColor.whiteColor()
        boldButton.tintColor = UIColor.whiteColor()
        italicButton.tintColor = UIColor.whiteColor()
        
        // Misc
        helperLabel.textColor = UIColor.blackColor()
    }
    
    func whiteColorMode() {
        // View
        view.backgroundColor = UIColor.whiteColor()
        writerTextView.backgroundColor = UIColor.whiteColor()
        writerTextView.textColor = UIColor.blackColor()
        writerTextView.keyboardAppearance = UIKeyboardAppearance.Light
        
        // Toolbar
        toolbar.barStyle = .Default
        saveButton.tintColor = UIColor.offBlackColor()
        tagButton.tintColor = UIColor.offBlackColor()
        listButton.tintColor = UIColor.offBlackColor()
        boldButton.tintColor = UIColor.offBlackColor()
        italicButton.tintColor = UIColor.offBlackColor()
        
        // Misc
        helperLabel.textColor = UIColor.blackColor()
        
    }
    
    func blackColorMode() {
        // View
        view.backgroundColor = UIColor.offBlackColor()
        writerTextView.backgroundColor = UIColor.offBlackColor()
        writerTextView.textColor = UIColor.whiteColor()
        writerTextView.keyboardAppearance = UIKeyboardAppearance.Dark
        
        // Toolbar
        toolbar.barStyle = .Black
        saveButton.tintColor = UIColor.whiteColor()
        tagButton.tintColor = UIColor.whiteColor()
        listButton.tintColor = UIColor.whiteColor()
        boldButton.tintColor = UIColor.whiteColor()
        italicButton.tintColor = UIColor.whiteColor()
        // Still need to figure out list button - it's still giving black text
        
        // Misc
        helperLabel.textColor = UIColor.whiteColor()
    }
}
