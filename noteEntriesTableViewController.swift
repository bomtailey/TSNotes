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
    // named views so we can pass touch through to tablecll
    
    
    // Properties fron NoteBaseTableController
    var managedObjectContext: NSManagedObjectContext!
    var noteBaseRecord: NoteBase!
    var noteName = String()
    var noteCreateDate = NSDate()

    var bNewNote = true
    var noteRecord: Note!
    
    var bIsRestore = true
    
    var myViewController = UIViewController()
    
    
    let calendar = NSCalendar.currentCalendar()
//    var dateOnlyComponents1 = calendar.components([.Day, .Month, .Year],  fromDate: noteCreateDate)
    
//    var noteEntries = [TSNote]()
//    var noteEntry = TSNote()
    
    let displayDateFormatter = NSDateFormatter()
    let sortableDateOnlyFormatter = NSDateFormatter()
    let displayDateOnlyFormatter = NSDateFormatter()
    let displayTimeOnlyFormatter = NSDateFormatter()
    
    // Temporary debug vars
    var sectionName = String()
    var noteText = String()
    var noteModDateTime = NSDate()

    
    override func viewDidLoad() {
        
        
        
        super.viewDidLoad()
        
        // temp move to see if we can get restore decode called
        //return ()
        
//        noteName = (noteBaseRecord.valueForKey("noteName") as? String!)!
//        navigationItem.title = noteName

        displayDateFormatter.dateFormat = "h:mm a  EEEE, MMMM d, yyyy"
        sortableDateOnlyFormatter.dateFormat = "yyyy.MM.dd"
        
        displayDateOnlyFormatter.dateFormat = "EEEE MMMM,d yyyy"  // "EEEE, d MMMM yyyy"

        displayTimeOnlyFormatter.dateFormat = "h:mm a"
        
 /*
        // try fetchcontroller fetch
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
         */

        let large = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
        let small = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        let point = CGPoint(x: 200, y: 200)
        large.convertPoint(point, toView: small)
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
      //  super.viewWillAppear(animated)
        
/*
        if managedObjectContext == nil {
            managedObjectContext = getManagedContext ()
            if managedObjectContext == nil {
                print("managedObjectContext has nil value")
                //exit(0)
            }
        }
        
 */
        
        noteName = noteBaseRecord.noteName!
//        noteName = (noteBaseRecord.valueForKey("noteName") as? String!)!
        navigationItem.title = noteName

        // try fetchcontroller fetch
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
        

        
    }
    
    
    // Enable row deletes
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == .Delete) {
            // Fetch Record
            let record = fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
            
            // Delete Record
            managedObjectContext.deleteObject(record)
            
            // Update noteBaseReord
            var count = noteBaseRecord.valueForKey("noteCount") as! Int
            count -= 1
            noteBaseRecord.setValue(count, forKey:"noteCount")
            
            do {
                try managedObjectContext.save()
                //5
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
            
        }
    }
    
    
    
    
    // Pass touch event through to cell
     func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        for subview in view.subviews as [UIView] {
            if !subview.hidden && subview.alpha > 0 && subview.userInteractionEnabled && subview.pointInside(view.convertPoint(point, toView: subview), withEvent: event) {
                return true
            }
        }
        return false
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
            
        case NSFetchedResultsChangeType(rawValue: 0)!:
            // iOS 8 bug - Do nothing if we get an invalid change type.
            break;

            
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
            
            // Mark - TEB: for some reason, adds are getting marked as moves (because they're child objects?) and the
            // tableview doesn't get updated so we're going to do it explicity which I think, in princple, we shouldn't have to
            
            if bNewNote {
                tableView.reloadData()
            }
            break;
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }

        

    // Configure table cell
    func configureCell(cell: TSNoteEntriesTableCell, atIndexPath indexPath: NSIndexPath) {
        
        // Fetch Record
        let record = fetchedResultsController.objectAtIndexPath(indexPath)
        
        // Update Cell
        if let noteModifiedTime = record.valueForKey("noteModifiedDateTime") as? String {
            noteText = (record.valueForKey("noteText") as? String)!

            cell.noteTextView.text = record.valueForKey("noteText") as? String

            // turn selectable off.  It's set to true in storyboard because if it isn't, the UI
            // ignores the font spec in storyboard.  But I don't want the text to be selectable
            cell.noteTextView.selectable = false
            
            cell.noteTextView.scrollRangeToVisible(NSMakeRange(0, 1))

            let timeDate = "\(noteModifiedTime)"  // - \(record.valueForKey("noteModifiedDateDay"))"
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
            
            // reformat the sectionName info
            let doDate = sortableDateOnlyFormatter.dateFromString(sectionName)
            let sectionNameReformatted = displayDateOnlyFormatter.stringFromDate(doDate!)
            return sectionNameReformatted
        }
        
        return ""
  }
    
    // Set section header font/size
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header = view as! UITableViewHeaderFooterView
        //make the background color light blue
        header.contentView.backgroundColor = UIColor(colorLiteralRed: 0.84, green: 0.93, blue: 0.93, alpha: 1.0)
        //UIColor(colorWithRed:0.62, colorWithGreen:0.80, colorWithBlue:0.81, alpha:1.0)
        header.textLabel?.font = UIFont(name: "Times New Roman", size: 15)
        header.textLabel?.textAlignment = NSTextAlignment.Center

        header.textLabel?.font = UIFont.boldSystemFontOfSize(16)
        
        
    }
    
   
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    //    NSLog("Selected section is: \(indexPath.section) and row is: \(indexPath.row)")
      
        // This is to restore the color scheme to the cell after selection
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        

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

    
    // Preserve/restore state data if interrupted
    override func encodeRestorableStateWithCoder(coder: NSCoder) {
        //1
        coder.encodeObject(noteName, forKey: "noteName")
        coder.encodeObject(noteText, forKey: "noteText")
        coder.encodeObject(noteModDateTime, forKey: "noteModDateTime")
        coder.encodeBool(bNewNote, forKey: "bNewNote")
        
        //2
        super.encodeRestorableStateWithCoder(coder)
    }
    
    override func decodeRestorableStateWithCoder(coder: NSCoder) {
        noteName = (coder.decodeObjectForKey("noteName")! as? String)!
        noteText = (coder.decodeObjectForKey("noteText")! as? String)!
        noteModDateTime = (coder.decodeObjectForKey("noteModDateTime")! as? NSDate)!
        bNewNote = (coder.decodeObjectForKey("bNewNote")! as? Bool)!
        
        
        super.decodeRestorableStateWithCoder(coder)
    }
    

    
    // Navigation
    @IBAction func cancelAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
 //       tableView.reloadData()
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
        
        if bNewNote { // set up new note
            noteText = ""
            
            // Add a note record object       
            let entityNote = NSEntityDescription.entityForName("Note", inManagedObjectContext: managedObjectContext)
            noteRecord = NSManagedObject(entity: entityNote!, insertIntoManagedObjectContext: managedObjectContext) as! Note
            
            
        } else { // set up note modification
            
            if let indexPath = tableView.indexPathForSelectedRow {
            
            // Fetch note record
            noteRecord = fetchedResultsController.objectAtIndexPath(indexPath) as! Note
                
            noteText = noteRecord.noteText!
//            noteText = (noteRecord.valueForKey("noteText") as? String)!
            noteModDateTime = noteRecord.noteModifiedDateTS!
//            noteModDateTime = (noteRecord.valueForKey("noteModifiedDateTS") as? NSDate)!
                
            }

            
        }
        
 
//        destinationVC.noteBaseRecord = noteBaseRecord
        destinationVC.bNewNote = bNewNote
        destinationVC.noteRecord = noteRecord
        destinationVC.noteName = noteName
 
//        destinationVC.noteText = noteText
//        destinationVC.noteModDateTime = noteModDateTime
        
 
    }
    
    
    
    @IBAction func unwindFromNoteEntry(sender: UIStoryboardSegue) {
   
        if let sourceViewController = sender.sourceViewController as? noteEntryViewController {
            
   //         var noteBaseRecord = Int()
            
            if bNewNote {
                
                
                // Update noteBaseReord
                var noteCount = noteBaseRecord.valueForKey("noteCount") as! Int
                noteCount += 1
                noteBaseRecord.setValue(noteCount, forKey:"noteCount")
                
                // Create Relationship
                
                let notes = noteBaseRecord.mutableSetValueForKey("notes")
                notes.addObject(noteRecord)

            }
            
            noteBaseRecord.modifyDateTS = NSDate()

//            noteBaseRecord.setValue(NSDate(), forKey:"modifyDateTS")
            
/*
            let noteModifyDate = sourceViewController.noteModDateTime
            
            noteRecord.setValue(sortableDateOnlyFormatter.stringFromDate(noteModifyDate!), forKey: "noteModifiedDateDay")
            noteRecord.setValue(displayTimeOnlyFormatter.stringFromDate(noteModifyDate!), forKey: "noteModifiedDateTime")
            noteRecord.setValue(noteModifyDate, forKey: "noteModifiedDateTS")
            noteRecord.setValue(sourceViewController.noteText, forKey: "noteText")
*/            

        // Create/update note entity
        
            do {
                try managedObjectContext.save()
                //5
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
            
            // this is what should be an unnecessary work-around for 1st add not showing
     //       if noteCount == 1 {
       //     }
            
        }
        
        
        /*
        
        func application(application: UIApplication, viewControllerWithRestorationIdentifierPath identifierComponents: [AnyObject], coder: NSCoder) -> UIViewController? {
           
            return myViewController
        }
 
        */
        
        tableView.reloadData()


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
