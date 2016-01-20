//
//  TSNote+CoreDataProperties.swift
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

extension TSNote {

    @NSManaged var noteCreateDateTime: NSDate?
    @NSManaged var noteModifyDateTime: NSDate?
    @NSManaged var noteText: String?
    @NSManaged var notesList: NSManagedObject?

}
