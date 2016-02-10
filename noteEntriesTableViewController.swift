//
//  noteEntriesTableViewController.swift - This is the table giving the entries for a particular note
//  TSNotes
//
//  Created by Jeanne's MacBook on 11/12/15.
//  Copyright © 2015 LCI. All rights reserved.
//

import UIKit
import CoreData


class noteEntriesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // Properties
    
    // Added for NSFetchedResultsController
    

//    @IBOutlet weak var tableView: UITableView!
    
    // Properties fron NoteBaseTableController
    var managedObjectContext: NSManagedObjectContext!
    var noteBaseRecord: NSManagedObject!
    var noteName = String()
    var noteCreateDate = NSDate()

    var bNewNote = true
    var noteRecord: NSManagedObject!
    
    
    let calendar = NSCalendar.currentCalendar()
//    var dateOnlyComponents1 = calendar.components([.Day, .Month, .Year],  fromDate: noteCreateDate)
    
    var noteEntries = [TSNote]()
    var noteEntry = TSNote()
    
    let displayDateFormatter = NSDateFormatter()
    let displayDateOnlyFormatter = NSDateFormatter()
    let displayTimeOnlyFormatter = NSDateFormatter()
    
    // Temporary debug vars
    var sectionName = String()
    var noteText = String()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        noteName = (noteBaseRecord.valueForKey("noteName") as? String!)!
        navigationItem.title = noteName

        displayDateFormatter.dateFormat = "EEEE, MMMM d, yyyy h:mm a"
        displayDateOnlyFormatter.dateFormat = "EEEE, MMMM d, yyyy"
        displayTimeOnlyFormatter.dateFormat = "h:mm a"
        
        // try fetchcontroller fetch
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }

    }
    
    
    // Initialize fetchedResultsController
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        /*
        
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "NoteBase")
        
        // Add Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: "createDateTS", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        */
        
        let notesFetchRequest = NSFetchRequest(entityName: "Note")
        
        let notesNoteBasePred = NSPredicate(format: "notesList.createDateTS == %@", self.noteCreateDate)
        notesFetchRequest.predicate = notesNoteBasePred
        
        // Add Sort Descriptor
        let sortDescriptor = NSSortDescriptor(key: "noteModifiedDateTS", ascending: false)
        notesFetchRequest.sortDescriptors = [sortDescriptor]

        
        // Initialize Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: notesFetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: "noteModifiedDateDay", cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    
    
    
    func configureTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120.0
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        }
    
        // MARK: -
        // MARK: Fetched Results Controller Delegate Methods
        func controllerWillChangeContent(controller: NSFetchedResultsController) {
            tableView.beginUpdates()
        }
    
        
        func controllerDidChangeContent(controller: NSFetchedResultsController) {
            tableView.endUpdates()
        }
    
        
        func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
            switch (type) {
            case .Insert:
                if let indexPath = newIndexPath {
                    tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                }
                break;
            case .Delete:
                if let indexPath = indexPath {
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                }
                break;
            case .Update:
                if let indexPath = indexPath {
                    let cell = tableView.cellForRowAtIndexPath(indexPath) as! TSNoteEntriesTableCell
                    configureCell(cell, atIndexPath: indexPath)
                }
                break;
            case .Move:
                if let indexPath = indexPath {
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                }
                
                if let newIndexPath = newIndexPath {
                    tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
                }
                break;
            }
        }
        
        func configureCell(cell: TSNoteEntriesTableCell, atIndexPath indexPath: NSIndexPath) {
            
            // Fetch Record
            let record = fetchedResultsController.objectAtIndexPath(indexPath)
            
            // Update Cell
            if let noteModifiedTime = record.valueForKey("noteModifiedDateTime") as? String {
                noteText = (record.valueForKey("noteText") as? String)!
                cell.noteTextView.text = record.valueForKey("noteText") as? String
                let timeDate = "\(noteModifiedTime) - \(record.valueForKey("noteModifiedDateDay"))"
                cell.noteEntryDateLabel.text = timeDate  //noteModifiedTime
            }
            
        }
        
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
 
        if let sections = fetchedResultsController.sections {
            NSLog("number of Sections: \(sections.count)")
            return sections.count
        }
        
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            NSLog("number Of Rows In Section: \(sectionInfo.numberOfObjects)")

            return sectionInfo.numberOfObjects
        }
        
        return 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("TSNoteEntriesTableCell", forIndexPath: indexPath) as! TSNoteEntriesTableCell

        //NSLog("working with section: \(indexPath.section)")

        // Configure Table View Cell
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        // Set name of section header
        if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            sectionName = sectionInfo.name
            return sectionInfo.name
        }
        
        return ""
  }
    
   /*
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        NSLog("Selected section is: \(indexPath.section) and row is: \(indexPath.row)")
        let noteEntry = noteEntriesSeparated [indexPath.section][indexPath.row]
        NSLog("Cell text is: \(noteEntry.noteText)")

    }
    */
    
    func applicationWillTerminate(application: UIApplication) {
        
        do {
            try self.managedObjectContext.save()
        } catch {
            let saveError = error as NSError
            print("\(saveError), \(saveError.userInfo)")
        }
    }
    
    
    func applicationDidEnterBackground(application: UIApplication) {
        do {
            try self.managedObjectContext.save()
        } catch {
            let saveError = error as NSError
            print("\(saveError), \(saveError.userInfo)")
        }
    }

    
    // Navigation
    @IBAction func cancelButton(sender: AnyObject) {
        
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }else{
            
            print("optional value")
            
            
        }
    }
    
    //let segueIndentifier = "presentNoteEntryEdit"
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
       let segID = segue.identifier
        
        // This is a superfluous
        guard   segID == "newNoteEntry" || segID == "modNoteEntry"  else {
            // Value requirements not met, do something
            return
        }
        
        let navVC = segue.destinationViewController as! UINavigationController
        let destinationVC = navVC.viewControllers.first as! noteEntryViewController

        bNewNote = segID == "newNoteEntry"
        
  
        if segue.identifier == "modNoteEntry" { // set up note modification
            
            if let indexPath = tableView.indexPathForSelectedRow {
                
            // Configure Note Entry View Controller
            
            // Fetch Record
            noteRecord = fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject

            // NSLog("noteEntriesTableViewController - Cell text is: \(noteEntry.noteText)")
            // print("row \(row) was selected")
            
            destinationVC.bNewNote = false
                
            }


            
            destinationVC.noteRecord = noteRecord
            
            
        } else {
            // Add a note
        }
        
    }
    
    
    @IBAction func unwindFromNoteEntry(sender: UIStoryboardSegue) {
   
        if let sourceViewController = sender.sourceViewController as? noteEntryViewController {
            
            if bNewNote {
                
                let entityNote = NSEntityDescription.entityForName("Note", inManagedObjectContext: managedObjectContext)
          //      let newNote = NSManagedObject(entity: entityNote!, insertIntoManagedObjectContext: managedObjectContext)
                 noteRecord = NSManagedObject(entity: entityNote!, insertIntoManagedObjectContext: managedObjectContext)
                
                // Populate note entity
                
        //        print("note date: \(noteModifyDate)")
        //        let dateOnly = displayDateOnlyFormatter.stringFromDate(noteModifyDate)
        //        print("Date only: \(dateOnly)")
        //        let timeOnly = displayTimeOnlyFormatter.stringFromDate(noteModifyDate)
        //        print("Date only: \(dateOnly)")
                
                // Update noteBaseReord
                var count = noteBaseRecord.valueForKey("noteCount") as! Int
                count += 1
                noteBaseRecord.setValue(count, forKey:"noteCount")
//                noteBaseRecord.setValue(noteRecord.valueForKey("noteModifiedDateTS"), forKey:"modifyDateTS")
                
                // Create Relationship
                
                let notes = noteBaseRecord.mutableSetValueForKey("notes")
                notes.addObject(noteRecord)

            }
            
           let noteModifyDate = sourceViewController.noteDateTime
            noteBaseRecord.setValue(noteModifyDate, forKey:"modifyDateTS")
            noteRecord.setValue(displayDateOnlyFormatter.stringFromDate(noteModifyDate), forKey: "noteModifiedDateDay")
            noteRecord.setValue(displayTimeOnlyFormatter.stringFromDate(noteModifyDate), forKey: "noteModifiedDateTime")
            noteRecord.setValue(noteModifyDate, forKey: "noteModifiedDateTS")
            noteRecord.setValue(sourceViewController.noteText, forKey: "noteText")
            

        // Create/update note entity
        
            do {
                try managedObjectContext.save()
                //5
    //            noteEntities.append(noteRecord)
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
        }
    }
    
    

    
    // Mark - Helper functions
    
    
        
    // Actions
    
    /*
    @IBAction func noteEntrySelectedForEdit(sender: UITapGestureRecognizer) {
        noteSelectedForEdit()
    }
    */
    
    func noteSelectedForEdit(){
        print("User selected note")
    
    }
 
}
