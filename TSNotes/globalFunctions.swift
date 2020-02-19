//
//  globalFunctions.swift
//  TSNotes
//
//  Created by Jeanne's MacBook on 7/18/18.
//  Copyright © 2018 LCI. All rights reserved.
//

import UIKit

class Utils {

    //MARK: - dateDifference: difference between two dates in days, hours, and minutes
    
    // Create a string with the difference between two dates in days, hours, and minutes
    static func dateDifference(laterDate: Date, earlierDate: Date) -> String {
        //Do your stuff here
        let elapsedSeconds = laterDate.timeIntervalSince(earlierDate)
    
    let intDays = Int(elapsedSeconds / Double(24 * 3600))
        
    let remainder1 = elapsedSeconds - Double(intDays) * Double(24 * 3600)
    let intHours = Int( remainder1/Double(3600))
 
    let remainder2 = remainder1 - Double(intHours) * Double( 3600)
    let intMinutes = Int(remainder2/Double(60))
    
    let differenceString = "\(intDays) d  \(intHours) h  \(intMinutes) m"
        
    return differenceString
    }
    
     // Count matches for search word(s) ===>  needs to change to include multiple search words
    static func nowString () -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd hh:mm:ss"
        return df.string(from: Date())
    }
        

    
    
    //MARK: - countAndHighlightMatchesHelper: highlight matches
    
    // Count matches for search word(s) ===>  needs to change to include multiple search words
static func countAndHighlightMatchesHelper( stringToFind: String, entireString: NSMutableAttributedString) -> (matchCount:Int, firstFindRange: NSRange)  {
        
        //var stringToSearch = entireString.mutableString
        
        //  equ highlightAttribute = NSBackgroundColorAttrib,value: UIColor.yellow
        
        let entireStringLen = entireString.mutableString.length
        var searchedStrLength = entireString.mutableString.length
        var searchRange = NSRange(location: 0, length: searchedStrLength )       //NSRange()
        var firstFindRange = NSRange(location: 0, length: searchedStrLength )       //NSRange()
        var msRange = NSRange( location: 0, length: searchedStrLength)
        
        let searchStrLen = stringToFind.count     
        
        var bFirstFind = Bool(true)
        
        var bCanSearchAgain = Bool(true)
        var matchCount = Int(0)
        
        repeat {
            
            msRange = entireString.mutableString.range(of: stringToFind, options: NSString.CompareOptions.caseInsensitive, range: searchRange)
            
            guard msRange.location <= entireStringLen - searchStrLen else {
                bCanSearchAgain = false
                return (matchCount, firstFindRange)
            }
            
           // print("found location is: \(msRange.location)")
            
            entireString.addAttribute( NSAttributedString.Key.backgroundColor,value: UIColor.yellow, range: msRange)
            
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

}
