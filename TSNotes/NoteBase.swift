//
//  NoteBase.swift
//  TSNotes
//
//  Created by Jeanne's MacBook on 6/29/16.
//  Copyright © 2016 LCI. All rights reserved.
//

import Foundation
import CoreData


class NoteBase: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    // MARK: Initialization
    
   /*
    init(_ noteTitleField: String = "", modifyDate: NSDate? = nil, createDate: NSDate? = nil, noteCount: Int? = nil,
        entityName: String, MOC : NSManagedObjectContext?) {
        
        let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: MOC!)

        super.init(entity: entity!, insertIntoManagedObjectContext: MOC)
 
        let nowDate = NSDate()
        dayTimePeriodFormatter.dateFormat = "MMM d,yyyy h:m a"
        
        
        if let modifyDate = modifyDate {
            modifyDateTS = modifyDate
        } else {
            self.modifyDateTS = nowDate
        }
        
        if let createDate = createDate {
            self.createDateTS = createDate
        } else {
            self.createDateTS = nowDate
        }
        
        if let possnoteCount = noteCount {
            self.noteCount = possnoteCount
        } else {
            self.noteCount = 0
        }
        
        self.noteName = noteTitleField
        if noteName!.isEmpty {
            self.noteName = dayTimePeriodFormatter.stringFromDate(nowDate)
        }
        
    }
    */
    
}
