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
