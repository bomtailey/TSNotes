//
//  TSNote.swift
//  TSNotes
//
//  Created by Jeanne's MacBook on 11/6/15.
//  Copyright © 2015 LCI. All rights reserved.
//

import UIKit


// Types

/*  12/4/15 this is the membership of a note itself

struct TSNotesKey {
    static let dateKey = 
}

*/

class TSNote: NSObject {
  
    // MARK: Properties
    
    var createDateTime: NSDate
    var modifyDateTime: NSDate
    var noteText: String
    
    let dayTimePeriodFormatter = NSDateFormatter()

    
    // MARK: Initialization
    
    init(_ noteText: String = "", modifyDate: String? = nil, createDate: String? = nil) {
        
       let nowDate = NSDate()
        
        
      //  dayTimePeriodFormatter.dateFormat = "MMM d,yyyy h:m a"
        dayTimePeriodFormatter.dateFormat = "MM-d-yyyy h:m a"
     
        if let modifyDate = modifyDate {
            self.modifyDateTime = dayTimePeriodFormatter.dateFromString(modifyDate)!

        } else {
            self.modifyDateTime = nowDate
        }
        
        if let createDate = createDate {
            self.createDateTime = dayTimePeriodFormatter.dateFromString(createDate)!
        } else {
            self.createDateTime = nowDate
        }
    
        
        self.noteText = noteText
        if noteText.isEmpty {
            self.noteText = dayTimePeriodFormatter.stringFromDate(nowDate)
        }
        
    }
}
