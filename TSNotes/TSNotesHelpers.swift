//
//  TSNotesHelpers.swift
//  TSNotes
//
//  Created by Jeanne's MacBook on 8/15/17.
//  Copyright © 2017 LCI. All rights reserved.
//

import Foundation
import UIKit


// Count matches for search word(s) ===>  needs to change to include multiple search words
func countAndHighlightMatchesHelper( stringToFind: String, entireString: NSMutableAttributedString) -> (matchCount:Int, firstFindRange: NSRange)  {
    
    //var stringToSearch = entireString.mutableString
    
    //  equ highlightAttribute = NSBackgroundColorAttrib,value: UIColor.yellow
    
    let entireStringLen = entireString.mutableString.length
    var searchedStrLength = entireString.mutableString.length
    var searchRange = NSRange(location: 0, length: searchedStrLength )       //NSRange()
    var firstFindRange = NSRange(location: 0, length: searchedStrLength )       //NSRange()
    var msRange = NSRange( location: 0, length: searchedStrLength)
    
    let searchStrLen = stringToFind.characters.count
    
    var bFirstFind = Bool(true)
    
    var bCanSearchAgain = Bool(true)
    var matchCount = Int(0)
    
    repeat {
        
        msRange = entireString.mutableString.range(of: stringToFind, options: NSString.CompareOptions.caseInsensitive, range: searchRange)
        
        guard msRange.location <= entireStringLen - searchStrLen else {
            bCanSearchAgain = false
            return (matchCount, firstFindRange)
        }
        
        print("found location is: \(msRange.location)")
        
        entireString.addAttribute( NSBackgroundColorAttributeName,value: UIColor.yellow, range: msRange)
        
        // Maybe save first find location
        if bFirstFind {
            bFirstFind = false
            firstFindRange = msRange
        }
        
        matchCount += 1
        searchRange.location = msRange.location + searchStrLen
        searchedStrLength = entireStringLen - searchRange.location
        searchRange.length = searchedStrLength
        
        //                NSLog( "myMutableString after: \(self.myMutableString)")
            
        
    } while bCanSearchAgain
    
    return (matchCount, firstFindRange)
}


    // Implement list scroll behavior - 1 tap on header goes to top of list, 2 taps goes to bottom

    func setUpListScrolling () {
    
        // This implements tap/double tap on the navigation bar to scroll the list to the top or bottom
    let singleTap = UITapGestureRecognizer(target: self, action:#selector(self.singleTapAction(_:)))
    singleTap.delegate = self
    singleTap.numberOfTapsRequired = 1
    self.navigationController?.navigationBar.addGestureRecognizer(singleTap)

    let doubleTap = UITapGestureRecognizer(target: self, action:#selector(self.doubleTapAction(_:)))
    doubleTap.delegate = self
    doubleTap.numberOfTapsRequired = 2
    self.navigationController?.navigationBar.addGestureRecognizer(doubleTap)

    // This effects discrimination of single/double tap
    singleTap.require(toFail: doubleTap)
}



// Handle navigation bar single tap - scroll to the top
func singleTapAction (_ theObject: AnyObject) {
    
    guard numRecords > 0 else { return }
    
    if theObject.state == .ended {
        let indexPath = NSIndexPath(row: 0, section: 0)
        self.tableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: false)
    }
    
    // let sbHeight = searchBar.frame.height
    //tableView.contentOffset = CGPoint(x:0, y:searchBar.frame.height);
    
}

// Handle navigation bar double tap - scroll to the bottom
func doubleTapAction (_ theObject: AnyObject) {
    
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







