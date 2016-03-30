//
//  SearchResultsTableViewController.swift
//  justype
//
//  Created by Gibson Smiley on 3/24/16.
//  Copyright © 2016 Gibson Smiley. All rights reserved.
//

import UIKit

class SearchResultsTableViewController: UITableViewController, PageViewControllerChild {

    var searchResultsDataSource: [Note] = []
    var pageView: UIPageViewController?
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultsDataSource.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("searchResultCell", forIndexPath: indexPath)
        let note = searchResultsDataSource[indexPath.row]
        cell.textLabel?.text = String(note.text)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let pageViewController: PageViewController = self.pageView as? PageViewController,
            writerViewController = pageViewController.orderedViewControllers.first as? WriterViewController else {return}
        writerViewController.updateWithNote(searchResultsDataSource[indexPath.row])
        pageViewController.setViewControllers([writerViewController], direction: .Reverse, animated: true) { (_) -> Void in
            pageViewController.currentPage = 0
        }
    }

}
