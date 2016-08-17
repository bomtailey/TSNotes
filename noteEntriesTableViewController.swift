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
    
    var currentCell: TSNoteEntriesTableCell!
    
    
    let calendar = NSCalendar.currentCalendar()
    
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
        
        noteCreateDate = noteBaseRecord.createDateTS!

        displayDateFormatter.dateFormat = "h:mm a  EEEE, MMMM d, yyyy"
        sortableDateOnlyFormatter.dateFormat = "yyyy.MM.dd"
        displayDateOnlyFormatter.dateFormat = "EEEE MMMM,d yyyy"  // "EEEE, d MMMM yyyy"
        displayTimeOnlyFormatter.dateFormat = "h:mm a"
        
        // Mark: to implement dynamic row height
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150

        /*  *****  Don't think this is needed 7/11/16
        let large = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
        let small = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        let point = CGPoint(x: 200, y: 200)
        large.convertPoint(point, toView: small)
        */
    }
    
    
    // Initialize fetchedResultsController
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
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
        
        noteName = noteBaseRecord.noteName!
        navigationItem.title = noteName

        // try fetchcontroller fetch
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
        

        
    }
    
    
    
    /*      *****  Don't think this is needed
    // Pass touch event through to cell
     func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        for subview in view.subviews as [UIView] {
            if !subview.hidden && subview.alpha > 0 && subview.userInteractionEnabled && subview.pointInside(view.convertPoint(point, toView: subview), withEvent: event) {
                return true
            }
        }
        return false
    }
    */
    
    
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
        
        currentCell = cell
        
        // Fetch Record
        let record = fetchedResultsController.objectAtIndexPath(indexPath) as! Note
        
        // Update Cell
        if let noteModifiedTime = record.noteModifiedDateTime {
            
           let textLen = 100
            var textString = record.noteText!
            if textString.characters.count > textLen {
                let indx = textString.startIndex.advancedBy(textLen)
                textString = textString.substringToIndex(indx)
            }
            
             cell.noteTextView.text =  textString      // record.noteText

         //   cell.noteTextView.scrollRangeToVisible(NSMakeRange(0, 0))
            cell.noteTextView.setContentOffset(CGPointZero, animated: false)

            let timeDate = "\(noteModifiedTime)" 
            cell.noteEntryDateLabel.text = timeDate  
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()

        if currentCell != nil {
            currentCell.noteTextView.scrollRangeToVisible(NSMakeRange(0, 0))
        }
    }
        
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
 
        if let sections = fetchedResultsController.sections {
 //           NSLog("number of Sections: \(sections.count)")
            return sections.count
        }
        
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
//            NSLog("number Of Rows In Section: \(sectionInfo.numberOfObjects)")

            return sectionInfo.numberOfObjects
        }
        
        return 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("TSNoteEntriesTableCell", forIndexPath: indexPath) as! TSNoteEntriesTableCell

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
    
    
    
    
    //Set up row edit actions
    
    
    
    // Enable row deletes
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        
        let alertController = UIAlertController(title: "TS Notes", message: "Do you really want to delete?", preferredStyle: UIAlertControllerStyle.Alert)
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: {(alert :UIAlertAction!) in
            print("Cancel button tapped")
            tableView.reloadRowsAtIndexPaths ([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        })
        
        alertController.addAction(cancelAction)
        
        let deleteChoice = UITableViewRowAction(style: .Normal, title: "Delete") { action, index in
            print("delete button tapped")
            
            let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive, handler: {(alert :UIAlertAction!) in
                print("Delete button tapped")
                
                // Fetch Record
                let record = self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
                
                // Delete Record
                self.managedObjectContext.deleteObject(record)
                
                // Update noteBaseReord
//                var count = noteBaseRecord.valueForKey("noteCount") as! Int
                var count = self.noteBaseRecord.noteCount as! Int
                count -= 1
                self.noteBaseRecord.noteCount = count
//                self.noteBaseRecord.setValue(count, forKey:"noteCount")
                
                // Update modification date
                self.noteBaseRecord.modifyDateTS = NSDate()
                
                do {
                    try self.managedObjectContext.save()
                    //5
                } catch let error as NSError  {
                    print("Could not save \(error), \(error.userInfo)")
                }
                
            })
            
            alertController.addAction(deleteAction)
            
            
            self.presentViewController(alertController, animated: true, completion: nil)

        
        /*
            let deleteChoice = UITableViewRowAction(style: .Normal, title: "Delete") { action, index in
            print("delete button tapped")
            
        }
        */
            
        }
        
        
        deleteChoice.backgroundColor = UIColor.redColor()

    
        return [ deleteChoice]

    }
    
    

    // ******* ==> DON'T THINK THIS CODE IS EVER EXECUTED.  REPLACED BY editActionsForRowAtIndexPath
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
        
        let navVC = segue.destinationViewController as! UINavigationController
        let destinationVC = navVC.viewControllers.first as! noteEntryViewController

        bNewNote = segID == "newNoteEntry"
        
        if bNewNote { // set up new note
            destinationVC.noteText = ""
            
            // Add a note record object       
//            let entityNote = NSEntityDescription.entityForName("Note", inManagedObjectContext: managedObjectContext)
//            noteRecord = NSManagedObject(entity: entityNote!, insertIntoManagedObjectContext: managedObjectContext) as! Note
            
            
        } else { // set up note modification
            
            if let indexPath = tableView.indexPathForSelectedRow {
            
            // Fetch note record
            noteRecord = fetchedResultsController.objectAtIndexPath(indexPath) as! Note
                
            destinationVC.noteText = noteRecord.noteText!
            destinationVC.noteModDateTime = noteRecord.noteModifiedDateTS!
                
            }

            
        }
        
        destinationVC.bNewNote = bNewNote
        destinationVC.noteName = noteName
 
    }
    
    
    
    @IBAction func unwindFromNoteEntry(sender: UIStoryboardSegue) {
   
        if let sVC = sender.sourceViewController as? noteEntryViewController {
        
            if bNewNote {
               
                // Update noteBaseReord
                var noteCount = noteBaseRecord.valueForKey("noteCount") as! Int
                noteCount += 1
                noteBaseRecord.setValue(noteCount, forKey:"noteCount")
                
                // Add a note record object
                let entityNote = NSEntityDescription.entityForName("Note", inManagedObjectContext: managedObjectContext)
                noteRecord = NSManagedObject(entity: entityNote!, insertIntoManagedObjectContext: managedObjectContext) as! Note
                
                // Create Relationship
                
                let notes = noteBaseRecord.mutableSetValueForKey("notes")
                notes.addObject(noteRecord)

            }
            
            noteBaseRecord.modifyDateTS = NSDate()
            
            noteRecord.noteText = sVC.noteText
            noteRecord.noteModifiedDateDay = sortableDateOnlyFormatter.stringFromDate(sVC.noteModDateTime!)
            noteRecord.noteModifiedDateTime = displayTimeOnlyFormatter.stringFromDate(sVC.noteModDateTime!)
            noteRecord.noteModifiedDateTS  = sVC.noteModDateTime!

        // Create/update note entity
        
            do {
                try managedObjectContext.save()
                //5
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
                        
        }
        
        
    }
    
        
        /*
        
        func application(application: UIApplication, viewControllerWithRestorationIdentifierPath identifierComponents: [AnyObject], coder: NSCoder) -> UIViewController? {
           
            return myViewController
        }
 
        */
        


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

