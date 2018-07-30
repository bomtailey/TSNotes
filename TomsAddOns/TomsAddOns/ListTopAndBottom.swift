//
//  ListTopAndBottom.swift
//  TomsAddOns
//
//  Created by Jeanne's MacBook on 9/1/17.
//  Copyright © 2017 LCI. All rights reserved.
//

import Foundation

class ListTopAndBottom: UITableViewController, UIGestureRecognizerDelegate {
    
// Implement list scroll behavior - 1 tap on header goes to top of list, 2 taps goes to bottom

    func setUpListScrolling () {
    
    // This implements tap/double tap on the navigation bar to scroll the list to the top or bottom

        // Single tap
        let singleTap = UITapGestureRecognizer(target: self, action:#selector(self.singleTapAction( _:,numRecords: Int )))
    singleTap.delegate = self
    singleTap.numberOfTapsRequired = 1
    self.navigationController?.navigationBar.addGestureRecognizer(singleTap)
    
    // Double tap
    let doubleTap = UITapGestureRecognizer(target: self, action:#selector(self.doubleTapAction(_:, numRecords: Int)))
    doubleTap.delegate = self
    doubleTap.numberOfTapsRequired = 2
    self.navigationController?.navigationBar.addGestureRecognizer(doubleTap)
    
        
    // Triple tap
    let tripleTap = UITapGestureRecognizer(target: self, action:#selector(self.tripleTapAction(_:, numRecords: Int)))
    tripleTap.delegate = self
    tripleTap.numberOfTapsRequired = 3
    self.navigationController?.navigationBar.addGestureRecognizer(tripleTap)

    // This effects discrimination of single/double tap
    singleTap.require(toFail: doubleTap)
}



// Handle navigation bar single tap - scroll to the top
    func singleTapAction (_ theObject: AnyObject, numRecords: Int) {
    
        guard numRecords > 0 else { return }
        
        if theObject.state == .ended {
            let indexPath = NSIndexPath(row: 0, section: 0)
            self.tableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: false)
        }
        
        // let sbHeight = searchBar.frame.height
        //tableView.contentOffset = CGPoint(x:0, y:searchBar.frame.height);
    
    }

// Handle navigation bar double tap - scroll to the bottom
func doubleTapAction ( _ theObject: AnyObject, numRecords: Int) {
    
    guard numRecords > 0 else { return }
    
        if theObject.state == .ended {
            
            // I'm changing the logic here.  It works pretty well as is but doesn't make sense to me
            
            let sections = fetchedResultsController.sections
            let numSections = (sections?.count)! - 1
            let sectionInfo = sections![numSections]
            let numRows = sectionInfo.numberOfObjects - 1
            // let numRows = tableView( tableView, numberOfRowsInSection: numSections[ - 1
            let indexPath = NSIndexPath(row: numRows, section: numSections)
            self.tableView.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: false)
        }
    
        // let sbHeight = searchBar.frame.height
        //    tableView.contentOffset = CGPoint(x:0, y:searchBar.frame.height);
    
    }
    
    // Handle navigation bar triple tap - scroll to the bottom
    func tripleTapAction ( _ theObject: AnyObject, numRecords: Int) {
        
    }

    
}
