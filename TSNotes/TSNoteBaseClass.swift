//
//  TSNoteBaseClass.swift
//  TSNotes
//
//  Created by Jeanne's MacBook on 12/6/15.
//  Copyright © 2015 LCI. All rights reserved.
//

//import Foundation
//
//  TSNote.swift
//  TSNotes
//
//  Created by Jeanne's MacBook on 11/6/15.
//  Copyright © 2015 LCI. All rights reserved.
//

import UIKit
import CoreData

// Types

//  12/6/15 this is an entry in the list of notes

// Must call a designated initializer of the superclass 'NSManagedObject'


class TSNoteBaseClass: NSManagedObject {
    
    // MARK: Properties
    
    @NSManaged var createDateTime: NSDate
    @NSManaged var modifyDateTime: NSDate
    @NSManaged var noteTitleField: String
    @NSManaged var noteCount: Int
    
    
//    let dayTimePeriodFormatter = NSDateFormatter()
    
    
    // MARK: Initialization
    
    init(_ noteTitleField: String = "", modifyDate: NSDate? = nil, createDate: NSDate? = nil, noteCount: Int? = nil) {
        
//        super.init()
        let nowDate = NSDate()
//        dayTimePeriodFormatter.dateFormat = "MMM d,yyyy h:m a"
        
        if let modifyDate = modifyDate {
            self.modifyDateTime = modifyDate
        } else {
            self.modifyDateTime = nowDate
        }
        
        if let createDate = createDate {
            self.createDateTime = createDate
        } else {
            self.createDateTime = nowDate
        }
        
        if let possnoteCount = noteCount {
            self.noteCount = possnoteCount
        } else {
            self.noteCount = 0
        }
       
        self.noteTitleField = noteTitleField
        if noteTitleField.isEmpty {
            self.noteTitleField = dayTimePeriodFormatter.stringFromDate(nowDate)
        }
        
    }
}
