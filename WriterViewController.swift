//
//  WriterViewController.swift
//  justype
//
//  Created by Gibson Smiley on 3/19/16.
//  Copyright © 2016 Gibson Smiley. All rights reserved.
//

import UIKit

class WriterViewController: UIViewController {
    
    @IBOutlet weak var writerTextView: UITextView!
    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet weak var successLabel: UILabel!
    
    var note: Note?
    
    // MARK: - View
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        successLabel.hidden = true
        
        // Something is happening with the page view controller after the writerview is initialy loaded, so that once returning to the writer view from the list view something in the page controller is "catching" the first responder, therefor stopping it. This hacky fix pauses the firstresponder long enough to avoid being "caught." firstresponder will be caught at 0.25.
        // Possible fix putting this code or a seperate function holding the becomefirstresponder and putting it in either writerview or pageview or both.
        
        
        
        

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        let seconds = Int64(0.3 * Double(NSEC_PER_SEC))
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, seconds), dispatch_get_main_queue()) {
            self.writerTextView.becomeFirstResponder()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toolbar.sizeToFit()
        writerTextView.inputAccessoryView = toolbar
    }
    
    // MARK: - Actions
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        if writerTextView.text.isEmpty {
            successLabel.hidden = false
            successLabel.text = "Swipe left to see your notes. 👉"
            writerTextView.resignFirstResponder()
        } else {
            if let note = self.note {
                note.text = self.writerTextView.text
            } else {
                writerTextView.resignFirstResponder()
                successLabel.hidden = false
                successLabel.text = "Note saved successfully. It's over there 👉"
                if let user = UserController.currentUser.identifier {
                    NoteController.createNote(writerTextView.text, ownerID: user, completion: { (note) -> Void in
                        if let note = self.note {
                            note.text = self.writerTextView.text
                        }
                    })
                }
                writerTextView.text = ""
                
            }
        }
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
