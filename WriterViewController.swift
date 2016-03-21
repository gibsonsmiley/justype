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
    
    var pageIndex: Int!
    var text: String!
    
    override func viewWillAppear(animated: Bool) {
        writerTextView.becomeFirstResponder()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        writerTextView.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserController.currentUser == nil {
            performSegueWithIdentifier("toAuthView", sender: self)
        }
        
        writerTextView.text = text

        toolbar.sizeToFit()
        writerTextView.inputAccessoryView = toolbar
        writerTextView.becomeFirstResponder()
    }
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        writerTextView.resignFirstResponder()
        if let user = UserController.currentUser {
            NoteController.createNote(writerTextView.text, user: user) { (note) -> Void in
                if let note = note {
                    //                    self.note = note
                    ViewController1.notes.append(note)
                } else {
                    print("Failed to create note")
                }
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
