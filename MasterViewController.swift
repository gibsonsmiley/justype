//
//  MasterViewController.swift
//  justype
//
//  Created by Gibson Smiley on 3/15/16.
//  Copyright © 2016 Gibson Smiley. All rights reserved.
//

import UIKit

class MasterViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()


        let vc0 = WriterViewController(nibName: "WriterView", bundle: nil)
        self.addChildViewController(vc0)
        self.scrollView.addSubview(vc0.view)
        vc0.didMoveToParentViewController(self)
        
        let vc1 = NotesListViewController(nibName: "NoteListView", bundle: nil)
        var frame1 = vc1.view.frame
        frame1.origin.x = self.view.frame.size.width
        vc1.view.frame = frame1
        self.addChildViewController(vc1)
        self.scrollView.addSubview(vc1.view)
        vc1.didMoveToParentViewController(self)
        
        let vc2 = SettingsViewController(nibName: "SettingsView", bundle: nil)
        var frame2 = vc2.view.frame
        frame2.origin.x = self.view.frame.size.width * 2
        vc2.view.frame = frame2
        self.addChildViewController(vc2)
        self.scrollView.addSubview(vc2.view)
        vc2.didMoveToParentViewController(self)
        
//        let vc3 = ViewController3(nibName: "ViewController3", bundle: nil)
//        var frame3 = vc3.view.frame
//        frame3.origin.x = self.view.frame.size.width * 3
//        vc3.view.frame = frame3
//        self.addChildViewController(vc3)
//        self.scrollView.addSubview(vc3.view)
//        vc3.didMoveToParentViewController(self)
        
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * 3, self.view.frame.size.height)
        
        
        
    
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
