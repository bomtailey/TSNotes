//
//  TSNoteBaseClass.swift
//  TSNotes
//
//  Created by Jeanne's MacBook on 12/6/15.
//  Copyright © 2015 LCI. All rights reserved.
//

import Foundation
//
//  TSNote.swift
//  TSNotes
//
//  Created by Jeanne's MacBook on 11/6/15.
//  Copyright © 2015 LCI. All rights reserved.
//

import UIKit


// Types

//  12/6/15 this is an entry in the list of notes


class TSNoteBaseClass: NSObject {
    
    // MARK: Properties
    
    var createDateTime: NSDate
    var modifyDateTime: NSDate
    var noteTitle: String
    var noteCount: Int
    
    
    let dayTimePeriodFormatter = NSDateFormatter()
    
    
    // MARK: Initialization
    
    init(_ noteTitle: String = "", modifyDate: String? = nil, createDate: String? = nil, noteCount: Int? = nil) {
        
        let nowDate = NSDate()
        dayTimePeriodFormatter.dateFormat = "MMM d,yyyy h:m a"
        
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
        
        if let possnoteCount = noteCount {
            self.noteCount = possnoteCount
        } else {
            self.noteCount = 0
        }
       
        self.noteTitle = noteTitle
        if noteTitle.isEmpty {
            self.noteTitle = dayTimePeriodFormatter.stringFromDate(nowDate)
        }
        
    }
}
