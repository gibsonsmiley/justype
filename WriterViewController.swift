//
//  WriterViewController.swift
//  justype
//
//  Created by Gibson Smiley on 3/19/16.
//  Copyright © 2016 Gibson Smiley. All rights reserved.
//

import UIKit

class WriterViewController: UIViewController, UITextViewDelegate, PageViewControllerChild {
    
    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet weak var successLabel: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var tagButton: UIBarButtonItem!
    @IBOutlet weak var listButton: UIBarButtonItem!
    @IBOutlet weak var boldButton: UIBarButtonItem!
    @IBOutlet weak var italicButton: UIBarButtonItem!
    
    
    var pageView: UIPageViewController?
    var note: Note?
    
    
    // MARK: - View
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
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
        setupKeyboardNotifications()
        let titleFont : UIFont = UIFont(name: "Avenir-Black", size: 17.0)!
        saveButton.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.darkGrayColor(), NSFontAttributeName: titleFont], forState: .Normal)
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("preferredContentSizeChanged"), name: UIContentSizeCategoryDidChangeNotification, object: nil)
        
        createTextView()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        writerTextView.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    
    // MARK: - Text Kit
    
    var writerTextView: UITextView!
    var textStorage: SyntaxHighlightTextStorage!
    
    func preferredContentSizeChanged(notification: NSNotification) {
        writerTextView.font = UIFont(name: "Avenir-Medium", size: 17.0)!
    }
    
    func createTextView() {
        let attrs = [NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 17.0)!]
        
        let attrString = NSAttributedString(string: note?.text ?? "", attributes: attrs)
        textStorage = SyntaxHighlightTextStorage()
        textStorage.appendAttributedString(attrString)
        
        let newTextViewRect = view.bounds
        
        let layoutManager = NSLayoutManager()
        
        let containerSize = CGSize(width: newTextViewRect.width, height: CGFloat.max)
        let container = NSTextContainer(size: containerSize)
        container.widthTracksTextView = true
        layoutManager.addTextContainer(container)
        textStorage.addLayoutManager(layoutManager)
        
        writerTextView = UITextView(frame: newTextViewRect, textContainer: container)
        writerTextView.delegate = self
        view.addSubview(writerTextView)
        
        writerTextView.frame = view.bounds
        
        
        writerTextView.inputAccessoryView = toolbar
    }
    
    
    
    
    // MARK: - Actions
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        if writerTextView.text.isEmpty {
            successLabel.hidden = false
            successLabel.text = "Swipe left to see your notes 👉"
            writerTextView.resignFirstResponder()
        } else {
            if let note = self.note {
                note.text = self.writerTextView.text
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
                    NoteController.createNote(writerTextView.text, ownerID: user, completion: { (note) -> Void in
                        if let note = self.note {
                            note.text = self.writerTextView.text
                        }
                    })
                }
            }
            writerTextView.text = ""
        }
    }
    
    func updateWithNote(note: Note) {
        self.note = note
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
    
    
    // MARK: - Toolbar Actions
    
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
    
    @IBAction func tagToolbarButtonTapped(sender: AnyObject) {
        writerTextView.insertText("#")
    }
    
    @IBAction func listToolbarButtonTapped(sender: AnyObject) {
        writerTextView.insertText("•")
    }
    
    @IBAction func boldToolbarButtonTapped(sender: AnyObject) {
        if boldButton.title == "UnBold" {
            boldButton.title = "Bold"
            writerTextView.insertText("*")
        } else {
            boldButton.title = "UnBold"
            writerTextView.insertText("*")
        }
    }
    
    @IBAction func italicToolbarButtonTapped(sender: AnyObject) {
        if italicButton.title == "UnItalic" {
            italicButton.title = "Italic"
        } else {
            italicButton.title = "UnItalic"
        }
    }
}
