//
//  TSNListEntryModel+CoreDataProperties.swift
//  TSNotes
//
//  Created by Jeanne's MacBook on 1/8/16.
//  Copyright © 2016 LCI. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension TSNListEntryModel {

    @NSManaged var noteCreateTS: NSDate?
    @NSManaged var noteEntriesCount: NSNumber?
    @NSManaged var noteModifyTS: NSDate?
    @NSManaged var noteName: String?
    @NSManaged var notes: NSSet?

}
