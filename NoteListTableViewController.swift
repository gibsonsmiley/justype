//
//  NoteListTableViewController.swift
//  justype
//
//  Created by Gibson Smiley on 3/21/16.
//  Copyright © 2016 Gibson Smiley. All rights reserved.
//

import UIKit

class NoteListTableViewController: UITableViewController, UISearchBarDelegate, PageViewControllerChild {
    
    // MARK: - Outlets
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet weak var helperLabel: UILabel!
    @IBOutlet weak var doneToolbarButton: UIBarButtonItem!
    @IBOutlet weak var settingsNavBarButton: UIBarButtonItem!
    @IBOutlet var noteTableView: UITableView!
    
    // MARK: - Properties
    
    static let sharedController = NoteListTableViewController()
    var pageView: UIPageViewController?
    var notes = [Note]()
    var filteredNotes: [Note] = []
    var selectedRow: NSIndexPath?
    let titleFont : UIFont = UIFont(name: "Avenir-Medium", size: 22.0)!
    var firstTime: Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(kLongPressOptions)
    }
    let kLongPressOptions = "longPressOptions"
    
    var colorMode: Int! {
        return NSUserDefaults.standardUserDefaults().integerForKey("colorMode")
    }
    
    var usersFont: String! {
        return NSUserDefaults.standardUserDefaults().stringForKey("fontStyle")
    }
    
    var usersFontSize: Float! {
        if NSUserDefaults.standardUserDefaults().floatForKey("fontSize") == 0.0 {
            return 17.0
        } else {
            return NSUserDefaults.standardUserDefaults().floatForKey("fontSize")
        }
    }
    
    func currentUser() {
        if UserController.sharedController.currentUser != nil {
            loadNotesForUser(UserController.sharedController.currentUser)
            tableView.reloadData()
            
            if NSUserDefaults.standardUserDefaults().boolForKey(kLongPressOptions) == false {
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: kLongPressOptions)
                NSUserDefaults.standardUserDefaults().synchronize()
                firstTimer()
            }
            
            if NSUserDefaults.standardUserDefaults().boolForKey(kLongPressOptions) == false {
                firstTimer()
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: kLongPressOptions)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
    }
    
    // MARK: - View
    
    override func viewWillAppear(animated: Bool) {
        changeColorMode()
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.inputAccessoryView = toolbar
        tableView.keyboardDismissMode = .Interactive
        notificationCenter()
        gestureCenter()
        
        self.searchBar.keyboardAppearance = .Dark
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        currentUser()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("Memory warning on NoteListTableView")
    }
    
    
    // MARK: - Actions
    
    func helper(label: UILabel, text: String?) {
        label.text = text
        label.hidden = false
        self.helperLabel.fadeOut(completion: {
            (finished: Bool) -> Void in
            label.alpha = 1.0
            label.hidden = true
        })
    }
    
    func gestureCenter() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(NoteListTableViewController.longPress(_:)))
        self.view.addGestureRecognizer(longPressRecognizer)
    }
        
    func reload() {
        notes = []
        tableView.reloadData()
    }
    
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
    
    func firstTimer() {
        self.helperLabel.hidden = false
        self.helperLabel.longFadeOut(completion : {
            (finished: Bool) -> Void in
            self.helperLabel.alpha = 1.0
            self.helperLabel.hidden = true
        })
    }
    
    func notificationCenter() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NoteListTableViewController.localNotificationFired), name: "NoteActionSheet", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NoteListTableViewController.reload), name: "userLoggedOut", object: nil)
    }
    
    func localNotificationFired() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let confirmController = UIAlertController(title: "Are you sure you'd like to delete this note? \n This action cannot be undone. 🤔", message: nil, preferredStyle: .ActionSheet)
        let shareAction = UIAlertAction(title: "Share", style: .Default) { (share) in
            let shareSheet = UIActivityViewController(activityItems: [UIActivityTypeMail as String, UIActivityTypeMessage as String, UIActivityTypePostToFacebook as String, UIActivityTypePostToTwitter as String, UIActivityTypeCopyToPasteboard as String], applicationActivities: [])
            self.presentViewController(shareSheet, animated: true, completion: nil)
        }
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive) { (delete) in
            self.presentViewController(confirmController, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        let deleteConfirmed = UIAlertAction(title: "Delete", style: .Destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            if let indexPath = self.selectedRow {
                let note = self.notes[indexPath.row]
                NoteController.deleteNote(note)
                self.tableView.beginUpdates()
                self.notes.removeAtIndex(indexPath.row)
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                self.tableView.endUpdates()
            }
        })
        
        let cancelConfirmed = UIAlertAction(title: "Cancel", style: .Cancel) { (cancel) in
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
        
        confirmController.addAction(deleteConfirmed)
        confirmController.addAction(cancelConfirmed)
        
//        alertController.addAction(shareAction)
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
            dispatch_async(dispatch_get_main_queue(), {
                cell.textLabel?.text = note.title
            })
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                let textViewText = String(note.text.mutableString)
                if let range = textViewText.rangeOfString("\n") {
                    let rangeOfString = textViewText.startIndex ..< range.endIndex
                    let firstLine = textViewText.substringWithRange(rangeOfString)
                    cell.textLabel?.text = firstLine
                } else {
                    let length = textViewText.characters.count
                    if length > 60 {
                        let firstLine = (textViewText as NSString).substringToIndex(60)
                        cell.textLabel?.text = firstLine
                    } else {
                        let firstLine = (textViewText as NSString).substringToIndex(length)
                        cell.textLabel?.text = firstLine
                    }
                }
            })
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let note = notes[indexPath.row]
            NoteController.deleteNote(note)
            tableView.beginUpdates()
            self.notes.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            tableView.endUpdates()
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
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
            cell.backgroundColor = UIColor.clearColor()
        if colorMode == 0 {
            cell.textLabel?.textColor = UIColor.blackColor()
        } else if colorMode == 1 {
            cell.textLabel?.textColor = UIColor.blackColor()
        } else if colorMode == 2 {
            cell.textLabel?.textColor = UIColor.whiteColor()
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
        view.backgroundColor = UIColor.notesYellow()
        navBar.barTintColor = UIColor.notesYellow()
        noteTableView.backgroundColor = UIColor.notesYellow()
        toolbar.barStyle = .Black
        searchBar.backgroundColor = UIColor.notesYellow()
        searchBar.barStyle = .Default
        searchBar.keyboardAppearance = UIKeyboardAppearance.Dark
        doneToolbarButton.tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.blackColor(), NSFontAttributeName: titleFont]
        settingsNavBarButton.tintColor = UIColor.darkGrayColor()
        
        // Table View
        tableView.backgroundColor = UIColor.notesYellow()
        
        // Misc
        helperLabel.textColor = UIColor.blackColor()
        
    }
    
    func whiteColorMode() {
        // View
        view.backgroundColor = UIColor.whiteColor()
        navBar.barTintColor = UIColor.whiteColor()
        noteTableView.backgroundColor = UIColor.whiteColor()
        toolbar.barStyle = .Default
        searchBar.backgroundColor = UIColor.whiteColor()
        searchBar.barStyle = .Default
        searchBar.keyboardAppearance = UIKeyboardAppearance.Default
        doneToolbarButton.tintColor = UIColor.blackColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.blackColor(), NSFontAttributeName: titleFont]
        settingsNavBarButton.tintColor = UIColor.darkGrayColor()
        
        // Table View
        tableView.backgroundColor = UIColor.whiteColor()
        
        
        
        // Misc
        helperLabel.textColor = UIColor.blackColor()
    }
    
    func blackColorMode() {
        // View
        view.backgroundColor = UIColor.offBlackColor()
        navBar.barTintColor = UIColor.offBlackColor()
        noteTableView.backgroundColor = UIColor.offBlackColor()
        toolbar.barStyle = .Black
        searchBar.backgroundColor = UIColor.offBlackColor()
        searchBar.barStyle = .Black
        searchBar.keyboardAppearance = UIKeyboardAppearance.Dark
        doneToolbarButton.tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName: titleFont]
        settingsNavBarButton.tintColor = UIColor.lightGrayColor()
        
        // Table View
        tableView.backgroundColor = UIColor.offBlackColor()
        
        // Misc
        helperLabel.textColor = UIColor.whiteColor()
    }
}