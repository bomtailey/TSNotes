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
    
    var managedObjectContext: NSManagedObjectContext!

 //   var noteEntries = [TSNote]()
    var noteBaseEntity = [NSManagedObject]()
    var noteEntities = [NSManagedObject]()

    var noteEntriesSeparated = [[TSNote]]()
    
    var noteBaseRecord: NSManagedObject!

    var savedBaseIndex = 0
  //  var noteEntriesSeparated = [savedBaseIndex,[TSNote]]()
    var bNewNote = true
    
    
    var noteCreateDate = NSDate()
    
    let calendar = NSCalendar.currentCalendar()
//    var dateOnlyComponents1 = calendar.components([.Day, .Month, .Year],  fromDate: noteCreateDate)
    
    var noteName = String()
    var sectionModDate = String()
    
    var noteEntries = [TSNote]()
    var noteEntry = TSNote()
    
    
   // var longString = longString1
    
    
    let displayDateFormatter = NSDateFormatter()
    let displayDateOnlyFormatter = NSDateFormatter()
    let displayTimeOnlyFormatter = NSDateFormatter()
    
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
            
            return sectionInfo.name
        }
        
        return ""
  }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        NSLog("Selected section is: \(indexPath.section) and row is: \(indexPath.row)")
        let noteEntry = noteEntriesSeparated [indexPath.section][indexPath.row]
        NSLog("Cell text is: \(noteEntry.noteText)")

    }
    
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
        
        guard   segID == "newNoteEntry" || segID == "modNoteEntry"  else {
            // Value requirements not met, do something
            return
        }
        
        let navVC = segue.destinationViewController as! UINavigationController
        let destinationVC = navVC.viewControllers.first as! noteEntryViewController

        bNewNote = segID == "newNoteEntry"
        
        destinationVC.noteName = noteName
        destinationVC.bNewNote = bNewNote

        
        
        if segue.identifier == "modNoteEntry" {
            
            if let destinationVC = segue.destinationViewController as? noteEntriesTableViewController{
                if let indexPath = tableView.indexPathForSelectedRow {
                    // Fetch Record
                    let record = fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
                    
                    // Configure View Controller
                    destinationVC.noteCreateDate = (record.valueForKey("createDateTS") as? NSDate)!
                    
                    destinationVC.noteBaseRecord = record
                    destinationVC.managedObjectContext = managedObjectContext
                }
            }
            
            let row = self.tableView.indexPathForSelectedRow!.row
            let section = self.tableView.indexPathForSelectedRow!.section
            
            let noteEntry = noteEntriesSeparated [section][row]
            // NSLog("noteEntriesTableViewController - Cell text is: \(noteEntry.noteText)")
            // print("row \(row) was selected")
            
            destinationVC.bNewNote = false
            destinationVC.selectedNote = noteEntry
            
            
        }
        
    }
    
    
    @IBAction func unwindFromNoteEntry(sender: UIStoryboardSegue) {
   
        if let sourceViewController = sender.sourceViewController as? noteEntryViewController {
            
            if bNewNote {
  
                let entityNote = NSEntityDescription.entityForName("Note", inManagedObjectContext: managedObjectContext)
                let newNote = NSManagedObject(entity: entityNote!, insertIntoManagedObjectContext: managedObjectContext)
                
                // Populate note entity
                let noteModifyDate = sourceViewController.noteDateTime
                print("note date: \(noteModifyDate)")
                let dateOnly = displayDateOnlyFormatter.stringFromDate(noteModifyDate)
                print("Date only: \(dateOnly)")
                let timeOnly = displayTimeOnlyFormatter.stringFromDate(noteModifyDate)
                print("Date only: \(dateOnly)")
                newNote.setValue(displayDateOnlyFormatter.stringFromDate(noteModifyDate), forKey: "noteModifiedDateDay")
                newNote.setValue(displayTimeOnlyFormatter.stringFromDate(noteModifyDate), forKey: "noteModifiedDateTime")
                newNote.setValue(noteModifyDate, forKey: "noteModifiedDateTS")
                
                newNote.setValue(sourceViewController.noteText, forKey: "noteText")
       
                // Update noteBaseReord
                var count = noteBaseRecord.valueForKey("noteCount") as! Int
                count += 1
                noteBaseRecord.setValue(count, forKey:"noteCount")
                noteBaseRecord.setValue(newNote.valueForKey("noteModifiedDateTS"), forKey:"modifyDateTS")
                
                // Create Relationship
                
                let notes = noteBaseRecord.mutableSetValueForKey("notes")
                notes.addObject(newNote)

            }
        // Create/update note entity
        
            do {
                try managedObjectContext.save()
                //5
                noteEntities.append(newNote)
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
