//
//  NoteBase+CoreDataProperties.swift
//  
//
//  Created by Tom's Macbook Pro on 3/2/20.
//
//

import Foundation
import CoreData


extension NoteBase {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NoteBase> {
        return NSFetchRequest<NoteBase>(entityName: "NoteBase")
    }

    @NSManaged public var createDateTS: Date?
    @NSManaged public var latestNoteDate: Date?
    @NSManaged public var modifyDateTS: Date?
    @NSManaged public var noteCount: NSNumber?
    @NSManaged public var noteName: String?
    @NSManaged public var notes: NSSet?

}

// MARK: Generated accessors for notes
extension NoteBase {

    @objc(addNotesObject:)
    @NSManaged public func addToNotes(_ value: Note)

    @objc(removeNotesObject:)
    @NSManaged public func removeFromNotes(_ value: Note)

    @objc(addNotes:)
    @NSManaged public func addToNotes(_ values: NSSet)

    @objc(removeNotes:)
    @NSManaged public func removeFromNotes(_ values: NSSet)

}
