//
//  Note+CoreDataProperties.swift
//  TSNotes
//
//  Created by Jeanne's MacBook on 6/29/16.
//  Copyright © 2016 LCI. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Note {

    @NSManaged var noteModifiedDateDay: String?
    @NSManaged var noteModifiedDateTime: String?
    @NSManaged var noteModifiedDateTS: Date?
    @NSManaged var noteText: String?
    @NSManaged var notesList: NoteBase?

}
