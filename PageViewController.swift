//
//  PageViewController.swift
//  justype
//
//  Created by Gibson Smiley on 3/21/16.
//  Copyright © 2016 Gibson Smiley. All rights reserved.
//

import UIKit

protocol PageViewControllerChild {
    var pageView: UIPageViewController? {get set}
}

class PageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        dataSource = self
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController], direction: .Forward, animated: true, completion: nil)
        }
        
        for view in self.view.subviews {
            if view.isKindOfClass(UIScrollView) {
                if let scrollView = view as? UIScrollView {
                    scrollView.delegate = self
                }
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if UserController.currentUser == nil {
            performSegueWithIdentifier("toAuthView", sender: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("Memory warning on PageView")
    }
    
    lazy var orderedViewControllers: [UIViewController] = {
        return [
            self.newViewController("WriterViewController"),
            self.newViewController("NoteListTableViewController")
        ]
    }()
    
    private func newViewController(name: String) -> UIViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(name)
        if var pageVCChild = vc as? PageViewControllerChild {
            pageVCChild.pageView = self
        }
        return vc
    }

    
    // MARK: - Page View Controller Data Source
    
    override func setViewControllers(viewControllers: [UIViewController]?, direction: UIPageViewControllerNavigationDirection, animated: Bool, completion: ((Bool) -> Void)?) {
        super.setViewControllers(viewControllers, direction: direction, animated: true, completion: completion)
    }
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return nil
        }
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        return orderedViewControllers[nextIndex]
    }
    
    
    // MARK: - Get Rid Of Bounce
    
    var currentPage: Int = 0
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed == true {
            if previousViewControllers.first == orderedViewControllers.first {
                currentPage = 1
            } else if previousViewControllers.first == orderedViewControllers[1] {
                currentPage = 0
            }
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if currentPage == 0 && scrollView.contentOffset.x < scrollView.bounds.size.width {
            scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0)
        } else if currentPage == 1 && scrollView.contentOffset.x > scrollView.bounds.size.width {
            scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0)
            
        }
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if currentPage == 0 && scrollView.contentOffset.x <= scrollView.bounds.size.width {
            targetContentOffset.memory = CGPointMake(scrollView.bounds.size.width, 0)
        } else if currentPage == 1 && scrollView.contentOffset.x >= scrollView.bounds.size.width {
            targetContentOffset.memory = CGPointMake(scrollView.bounds.size.width, 0)
        }
    }
}