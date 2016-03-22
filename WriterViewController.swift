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
    
    var note: Note?
    
    // MARK: - View
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        writerTextView.becomeFirstResponder()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        writerTextView.becomeFirstResponder()
        writerTextView.endEditing(false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toolbar.sizeToFit()
        writerTextView.inputAccessoryView = toolbar
//        writerTextView.becomeFirstResponder()
    }
    
    // MARK: - Actions
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        if let note = self.note {
            note.text = self.writerTextView.text
        } else {
            if let user = UserController.currentUser.identifier {
                NoteController.createNote(writerTextView.text, ownerID: user, completion: { (note) -> Void in
                    if let note = self.note {
                        note.text = self.writerTextView.text
                    }
                })
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
