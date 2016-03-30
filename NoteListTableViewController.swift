//
//  NoteListTableViewController.swift
//  justype
//
//  Created by Gibson Smiley on 3/21/16.
//  Copyright © 2016 Gibson Smiley. All rights reserved.
//

import UIKit

class NoteListTableViewController: UITableViewController, UISearchBarDelegate, PageViewControllerChild {

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var toolbar: UIToolbar!
    
    var pageView: UIPageViewController?
    var user = UserController.currentUser
    var notes = [Note]()
    var filteredNotes: [Note] = []
    var selectedRow: NSIndexPath?
    let titleFont : UIFont = UIFont(name: "Avenir-Medium", size: 22.0)!
    
    override func viewDidLoad() {
        searchBar.inputAccessoryView = toolbar
        darkModeTrue()
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NoteListTableViewController.localNotificationFired), name: "NoteActionSheet", object: nil)
    
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(NoteListTableViewController.longPress(_:)))
        self.view.addGestureRecognizer(longPressRecognizer)

        let titleFont : UIFont = UIFont(name: "Avenir-Medium", size: 22.0)!
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.blackColor(), NSFontAttributeName: titleFont]
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        //tableView.reloadData()
        loadNotesForUser(user)
        NoteController.orderNotes(notes)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("Memory warning on NoteListTableView")
    }
    
    
    // MARK: - Actions
    
    func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizerState.Began {
            let touchPoint = longPressGestureRecognizer.locationInView(self.view)
            if let indexPath = tableView.indexPathForRowAtPoint(touchPoint) {
                self.selectedRow = indexPath
                let notifcation = UILocalNotification()
                UIApplication.sharedApplication().scheduleLocalNotification(notifcation)
            }
        }
    }

    @IBAction func doneButtonTapped(sender: AnyObject) {
        searchBar.resignFirstResponder()
    }

    func loadNotesForUser(user: User) {
        UserController.observeNotesForUser(user) { () -> Void in
            self.notes = user.notes
            self.tableView.reloadData()
        }
    }
    
    func localNotificationFired() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let shareAction = UIAlertAction(title: "Share", style: .Default) { (share) in
            let shareSheet = UIActivityViewController(activityItems: [UIActivityTypeMail, UIActivityTypeMessage, UIActivityTypePostToFacebook, UIActivityTypePostToTwitter, UIActivityTypeCopyToPasteboard], applicationActivities: [])
            self.presentViewController(shareSheet, animated: true, completion: nil)
        }
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: {
            (alert: UIAlertAction!) -> Void in
                if let selectedRow = self.selectedRow {
                let note = self.notes[selectedRow.row]
                NoteController.deleteNote(note)
                self.notes.removeAtIndex(selectedRow.row)
                self.tableView.deleteRowsAtIndexPaths([selectedRow], withRowAnimation: .Fade)
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(shareAction)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    // MARK: - Search
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filteredNotes = notes.filter({String($0.text).lowercaseString.containsString(searchText.lowercaseString)})
        tableView.reloadData()
    }


    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredNotes.count > 0 {
            return filteredNotes.count
        }
        return notes.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("noteCell", forIndexPath: indexPath)
        let note = filteredNotes.count > 0 ? filteredNotes[indexPath.row]: notes[indexPath.row]
        if note.title != "" {
            cell.textLabel?.text = note.title
        } else {
            let textViewText = String(note.text.mutableString)
            if let range = textViewText.rangeOfString("\n") {
                let rangeOfString = textViewText.startIndex ..< range.endIndex
                let firstLine = textViewText.substringWithRange(rangeOfString)
                cell.textLabel?.text = firstLine
            } else {
                let length = textViewText.characters.count
                if length > 30 {
                    let firstLine = (textViewText as NSString).substringToIndex(30)
                    cell.textLabel?.text = firstLine
                } else {
                    let firstLine = (textViewText as NSString).substringToIndex(length)
                    cell.textLabel?.text = firstLine
                }
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let note = notes[indexPath.row]
            NoteController.deleteNote(note)
            self.notes.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let pageViewController: PageViewController = self.pageView as? PageViewController,
            writerViewController = pageViewController.orderedViewControllers.first as? WriterViewController else {return}
        writerViewController.updateWithNote(notes[indexPath.row])
        pageViewController.setViewControllers([writerViewController], direction: .Reverse, animated: true) { (_) -> Void in
            pageViewController.currentPage = 0
        }
    }
    

    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toNote" {
            if let destinationViewController = segue.destinationViewController as? WriterViewController {
                _ = destinationViewController.view
                if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPathForCell(cell) {
                    let note = notes[indexPath.row]
                    destinationViewController.updateWithNote(note)
                }
            }
        }
    }
    
    // MARK: - Themes
    
    // Dark Mode
    
    func darkModeTrue() {
        if AppearanceController.darkMode == true {
            tableView.backgroundColor = UIColor.offBlackColor()
            searchBar.keyboardAppearance = UIKeyboardAppearance.Dark
            tableView.tableHeaderView?.backgroundColor = UIColor.offBlackColor()
            toolbar.barTintColor = UIColor.offBlackColor()
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if AppearanceController.darkMode == true {
            cell.backgroundColor = UIColor.clearColor()
            cell.textLabel?.textColor = UIColor.whiteColor()
        }
    }
}