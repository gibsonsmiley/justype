//
//  ViewController0.swift
//  justype
//
//  Created by Gibson Smiley on 3/17/16.
//  Copyright © 2016 Gibson Smiley. All rights reserved.
//

import UIKit

class WriterViewController: UIViewController {

    @IBOutlet weak var writerTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        writerTextView.becomeFirstResponder()
    }
    override func viewWillDisappear(animated: Bool) {
        writerTextView.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
