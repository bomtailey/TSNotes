//
//  NoteBase+CoreDataProperties.swift
//  TSNotes
//
//  Created by Jeanne's MacBook on 6/29/16.
//  Copyright © 2016 LCI. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//
//  Added latestNoteDate 7/20/18

import Foundation
import CoreData

extension NoteBase {

    @NSManaged var createDateTS: Date?
    @NSManaged var latestNoteDate: Date?
    @NSManaged var modifyDateTS: Date?
    @NSManaged var noteCount: NSNumber?
    @NSManaged var noteName: String?
    @NSManaged var notes: NSSet?

}
