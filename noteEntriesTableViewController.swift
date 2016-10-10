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
    var noteCreateDate = Date()

    var bNewNote = true
    var noteRecord: Note!
    
    var bIsRestore = true
    
    var myViewController = UIViewController()
    
    var currentCell: TSNoteEntriesTableCell!
    
    
    let calendar = Calendar.current
    
    let displayDateFormatter = DateFormatter()
    let sortableDateOnlyFormatter = DateFormatter()
    let displayDateOnlyFormatter = DateFormatter()
    let displayTimeOnlyFormatter = DateFormatter()
    
    // Temporary debug vars
    var sectionName = String()
    var noteText = String()
    var noteModDateTime = Date()

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        noteCreateDate = noteBaseRecord.createDateTS! as Date

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
    lazy var fetchedResultsController: NSFetchedResultsController = { () -> <<error type>> in 
        
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
    
    override func viewWillAppear(_ animated: Bool) {
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
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
            
        case NSFetchedResultsChangeType(rawValue: 0)!:
            // iOS 8 bug - Do nothing if we get an invalid change type.
            break;

            
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break;
            
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break;
            
            
        case .update:
            if let indexPath = indexPath {
                let cell = tableView.cellForRow(at: indexPath) as! TSNoteEntriesTableCell
                configureCell(cell, atIndexPath: indexPath)
            }
            break;

        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
            
            // Mark - TEB: for some reason, adds are getting marked as moves (because they're child objects?) and the
            // tableview doesn't get updated so we're going to do it explicity which I think, in princple, we shouldn't have to
            
            if bNewNote {
                tableView.reloadData()
            }
            break;
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }

        

    // Configure table cell
    func configureCell(_ cell: TSNoteEntriesTableCell, atIndexPath indexPath: IndexPath) {
        
        currentCell = cell
        
        // Fetch Record
        let record = fetchedResultsController.object(at: indexPath) as! Note
        
        // Update Cell
        if let noteModifiedTime = record.noteModifiedDateTime {
            
           let textLen = 100
            var textString = record.noteText!
            if textString.characters.count > textLen {
                let indx = textString.characters.index(textString.startIndex, offsetBy: textLen)
                textString = textString.substring(to: indx)
            }
            
             cell.noteTextView.text =  textString      // record.noteText

         //   cell.noteTextView.scrollRangeToVisible(NSMakeRange(0, 0))
            cell.noteTextView.setContentOffset(CGPoint.zero, animated: false)

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

    override func numberOfSections(in tableView: UITableView) -> Int {
 
        if let sections = fetchedResultsController.sections {
 //           NSLog("number of Sections: \(sections.count)")
            return sections.count
        }
        
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
//            NSLog("number Of Rows In Section: \(sectionInfo.numberOfObjects)")

            return sectionInfo.numberOfObjects
        }
        
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TSNoteEntriesTableCell", for: indexPath) as! TSNoteEntriesTableCell

        // Configure Table View Cell
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        // Set name of section header
        if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            sectionName = sectionInfo.name
            
            // reformat the sectionName info
            let doDate = sortableDateOnlyFormatter.date(from: sectionName)
            let sectionNameReformatted = displayDateOnlyFormatter.string(from: doDate!)
            return sectionNameReformatted
        }
        
        return ""
  }
    
    // Set section header font/size
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header = view as! UITableViewHeaderFooterView
        //make the background color light blue
        header.contentView.backgroundColor = UIColor(colorLiteralRed: 0.84, green: 0.93, blue: 0.93, alpha: 1.0)
        //UIColor(colorWithRed:0.62, colorWithGreen:0.80, colorWithBlue:0.81, alpha:1.0)
        header.textLabel?.font = UIFont(name: "Times New Roman", size: 15)
        header.textLabel?.textAlignment = NSTextAlignment.center

        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        
    }
    
   
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        // This is to restore the color scheme to the cell after selection
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func applicationWillTerminate(_ application: UIApplication) {
        
        do {
            try self.managedObjectContext.save()
        } catch {
            let saveError = error as NSError
            print("\(saveError), \(saveError.userInfo)")
        }
    }
    
    
    
    
    //Set up row edit actions
    
    
    
    // Enable row deletes
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        
        let alertController = UIAlertController(title: "TS Notes", message: "Do you really want to delete?", preferredStyle: UIAlertControllerStyle.alert)
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: {(alert :UIAlertAction!) in
            print("Cancel button tapped")
            tableView.reloadRows (at: [indexPath], with: UITableViewRowAnimation.automatic)
        })
        
        alertController.addAction(cancelAction)
        
        let deleteChoice = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            print("delete button tapped")
            
            let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: {(alert :UIAlertAction!) in
                print("Delete button tapped")
                
                // Fetch Record
                let record = self.fetchedResultsController.object(at: indexPath) as! NSManagedObject
                
                // Delete Record
                self.managedObjectContext.delete(record)
                
                // Update noteBaseReord
//                var count = noteBaseRecord.valueForKey("noteCount") as! Int
                var count = self.noteBaseRecord.noteCount as! Int
                count -= 1
                self.noteBaseRecord.noteCount = count as NSNumber?
//                self.noteBaseRecord.setValue(count, forKey:"noteCount")
                
                // Update modification date
                self.noteBaseRecord.modifyDateTS = Date()
                
                do {
                    try self.managedObjectContext.save()
                    //5
                } catch let error as NSError  {
                    print("Could not save \(error), \(error.userInfo)")
                }
                
            })
            
            alertController.addAction(deleteAction)
            
            
            self.present(alertController, animated: true, completion: nil)

        
        /*
            let deleteChoice = UITableViewRowAction(style: .Normal, title: "Delete") { action, index in
            print("delete button tapped")
            
        }
        */
            
        }
        
        
        deleteChoice.backgroundColor = UIColor.red

    
        return [ deleteChoice]

    }
    
    

    // ******* ==> DON'T THINK THIS CODE IS EVER EXECUTED.  REPLACED BY editActionsForRowAtIndexPath
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == .delete) {
            // Fetch Record
            let record = fetchedResultsController.object(at: indexPath) as! NSManagedObject
            
            // Delete Record
            managedObjectContext.delete(record)
            
            // Update noteBaseReord
            var count = noteBaseRecord.value(forKey: "noteCount") as! Int
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


    
    func applicationDidEnterBackground(_ application: UIApplication) {
        do {
            try self.managedObjectContext.save()
        } catch {
            let saveError = error as NSError
            print("\(saveError), \(saveError.userInfo)")
        }
    }

    
    // Preserve/restore state data if interrupted
    override func encodeRestorableState(with coder: NSCoder) {
        //1
        coder.encode(noteName, forKey: "noteName")
        coder.encode(noteText, forKey: "noteText")
        coder.encode(noteModDateTime, forKey: "noteModDateTime")
        coder.encode(bNewNote, forKey: "bNewNote")
        
        //2
        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        noteName = (coder.decodeObject(forKey: "noteName")! as? String)!
        noteText = (coder.decodeObject(forKey: "noteText")! as? String)!
        noteModDateTime = (coder.decodeObject(forKey: "noteModDateTime")! as? Date)!
        bNewNote = (coder.decodeObject(forKey: "bNewNote")! as? Bool)!
        
        
        super.decodeRestorableState(with: coder)
    }
    

    
    // Navigation
    @IBAction func cancelAction(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
 //       tableView.reloadData()
    }
    
    //let segueIndentifier = "presentNoteEntryEdit"
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let segID = segue.identifier
        
        let navVC = segue.destination as! UINavigationController
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
            noteRecord = fetchedResultsController.object(at: indexPath) as! Note
                
            destinationVC.noteText = noteRecord.noteText!
            destinationVC.noteModDateTime = noteRecord.noteModifiedDateTS!
                
            }

            
        }
        
        destinationVC.bNewNote = bNewNote
        destinationVC.noteName = noteName
 
    }
    
    
    
    @IBAction func unwindFromNoteEntry(_ sender: UIStoryboardSegue) {
   
        if let sVC = sender.source as? noteEntryViewController {
        
            if bNewNote {
               
                // Update noteBaseReord
                var noteCount = noteBaseRecord.value(forKey: "noteCount") as! Int
                noteCount += 1
                noteBaseRecord.setValue(noteCount, forKey:"noteCount")
                
                // Add a note record object
                let entityNote = NSEntityDescription.entity(forEntityName: "Note", in: managedObjectContext)
                noteRecord = NSManagedObject(entity: entityNote!, insertInto: managedObjectContext) as! Note
                
                // Create Relationship
                
                let notes = noteBaseRecord.mutableSetValue(forKey: "notes")
                notes.add(noteRecord)

            }
            
            noteBaseRecord.modifyDateTS = Date()
            
            noteRecord.noteText = sVC.noteText
            noteRecord.noteModifiedDateDay = sortableDateOnlyFormatter.string(from: sVC.noteModDateTime! as Date)
            noteRecord.noteModifiedDateTime = displayTimeOnlyFormatter.string(from: sVC.noteModDateTime! as Date)
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

