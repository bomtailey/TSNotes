//
//  TSNoteClass.swift
//  TSNotes
//
//  Created by Jeanne's MacBook on 1/15/16.
//  Copyright © 2016 LCI. All rights reserved.
//

import UIKit

class TSNote: NSObject {
    
    // MARK: Properties
    
//    var createDateTime: NSDate
    var modifyDateTime: NSDate
    var noteText: String
    
    
//    let dayTimePeriodFormatter = NSDateFormatter()
    
    
    // MARK: Initialization
    
    init(_ noteTitleField: String = "", modifyDate: NSDate? = nil, createDate: NSDate? = nil) {
        
        let nowDate = NSDate()
//        dayTimePeriodFormatter.dateFormat = "MMM d,yyyy h:m a"
        
        if let modifyDate = modifyDate {
       //     self.modifyDateTime = dayTimePeriodFormatter.dateFromString(modifyDate)!
            self.modifyDateTime = modifyDate
        } else {
            self.modifyDateTime = nowDate
        }
        
        /*  remove create date from note 1/20/16 since it's tied to
        if let createDate = createDate {
        //    self.createDateTime = dayTimePeriodFormatter.dateFromString(createDate)!
            self.createDateTime = createDate//
        } else {
            self.createDateTime = nowDate
        }
        */
        
        
        self.noteText = noteTitleField
        if noteTitleField.isEmpty {
            self.noteText = dayTimePeriodFormatter.stringFromDate(nowDate)
        }
        
    }

}
