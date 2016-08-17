
//
//  NoteBaseTableController.swift - this is the table listing all the notes
//  TSNotes
//
//  Created by Jeanne's MacBook on 11/6/15.
//  Copyright © 2015 LCI. All rights reserved.
//

import UIKit
import CoreData

class NoteBaseTableController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: Properties

    @IBOutlet weak var edtButton: UIBarButtonItem!
    
//    let ReuseIdentifierNoteListCell = "noteListTableViewCell"
    
    var managedObjectContext: NSManagedObjectContext!
    
    var noteCreateDate = NSDate()
    var noteTitle = String()

    var noteBaseRecord: NoteBase!

    var currentIndexPath: NSIndexPath?
    
    var titleString = ""
    var segueListNoteInstance : NoteBase!
    
    var selectedCreateDate = NSDate()
    
    let dayTimePeriodFormatter = NSDateFormatter()
    
    // dayTimePeriodFormatter.dateFormat = "EEEE, d MMMM yyyy h:m a"


    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        dayTimePeriodFormatter.dateFormat =  "EEEE MM/d/yy    h:mm a"
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem()
        
        
        // Show location of database
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        print("App Path: \(dirPaths)")
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if managedObjectContext == nil {
            managedObjectContext = getManagedContext ()
            if managedObjectContext == nil {
                print("managedObjectContext has nil value")
                //exit(0)
            }
        }
        
         // try fetchcontroller fetch
         do {
         try self.fetchedResultsController.performFetch()
         } catch {
         let fetchError = error as NSError
         print("\(fetchError), \(fetchError.userInfo)")
         }
 
        
        super.viewWillAppear(animated);
        

        
    }
    
    func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization before application launch.
        
        //      let appState = application.applicationState
        
         return true
         }
 
        
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // try fetchcontroller fetch
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }

        return true
    }
    
    // Initialize fetchedResultsController
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "NoteBase")
        
        // Add Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: "modifyDateTS", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Initialize Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    // MARK: -
    // MARK: Fetched Results Controller Delegate Methods
    
    /*
    static func viewControllerWithRestorationIdentifierPath(_: [,"NoteBaseTableController"], coder: NSCoder) -> UIViewController? {
        
        return self.managedObjectContext
    }
    */

    
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
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! noteListTableViewCell
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
    
    func configureCell(cell: noteListTableViewCell, atIndexPath indexPath: NSIndexPath) {
        
        noteBaseRecord = fetchedResultsController.objectAtIndexPath(indexPath)  as! NoteBase
        
            
        // Update Cell
        if let modifyDateTS = noteBaseRecord.valueForKey("modifyDateTS") as? NSDate {
            cell.noteTitleField.text = noteBaseRecord.valueForKey("noteName") as? String
            cell.noteModifyDate.text = dayTimePeriodFormatter.stringFromDate(modifyDateTS)
        }
        
        if let count = noteBaseRecord.valueForKey("noteCount") as? Int {
            cell.noteCount.text = String(count)            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        let alertController = UIAlertController(title: "TS Notes", message: "Recieved a memory warning", preferredStyle: UIAlertControllerStyle.Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        
        presentViewController(alertController, animated: true, completion: nil)
        
    }
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        // return the number of rows
        if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("noteListTableViewCell", forIndexPath: indexPath)
            as! noteListTableViewCell

        // Configure Table View Cell
        configureCell(cell, atIndexPath: indexPath)
        
    return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        
        return true
    }


    // Enable row deletes
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
 
    }
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {

        return ""
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
 
        
        // This is to restore the color scheme to the cell after selection
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
    

    //Set up row edit actions
    
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
                
                do {
                    try self.managedObjectContext.save()
                    //5
                } catch let error as NSError  {
                    print("Could not save \(error), \(error.userInfo)")
                }

            })
            
            alertController.addAction(deleteAction)
            
            
            self.presentViewController(alertController, animated: true, completion: nil)
    
            
        }
        
        deleteChoice.backgroundColor = UIColor.redColor()
        
        
        let editChoice = UITableViewRowAction(style: .Normal, title: "Edit") { action, index in
            print("edit button tapped")
            self.currentIndexPath = indexPath
            self.performSegueWithIdentifier("modifyNoteTitle", sender: self)
            tableView.reloadRowsAtIndexPaths ([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)

        }
        
        editChoice.backgroundColor = UIColor.grayColor()
        
        return [editChoice, deleteChoice]
    }
    
    /*
    override func tableView(tableView: UITableView,editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?  {
     
    }

    */
    // MARK: - Actions
    
    // Edit button action
    @IBAction func editButtonClicked(sender: AnyObject) {
        NSLog("edit button was clicked", 4)
    }

    
    // MARK: - Navigation
    
    
    // segue to noteEntriesTableViewController or TitleEntryViewController
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        

        // If we're adding a new note
        if segue.identifier == "AddnoteTitleField" {
            
            let destinationNavController = segue.destinationViewController as! UINavigationController
            let destinationVC = destinationNavController.topViewController as? TitleEntryViewController
            
            let entity =  NSEntityDescription.entityForName("NoteBase", inManagedObjectContext:managedObjectContext)
            noteBaseRecord = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedObjectContext) as! NoteBase
            
            destinationVC!.newTitleRequest = true
            destinationVC!.managedObjectContext = managedObjectContext
            destinationVC!.noteBaseRecord = noteBaseRecord
            
    } else {

            // we're showing the note entries or we're changing the note title
            
            // Fetch current base record
            let indexPath = tableView.indexPathForSelectedRow
            let usableIndexPath = (indexPath ?? currentIndexPath)
            
            noteBaseRecord = fetchedResultsController.objectAtIndexPath(usableIndexPath!) as! NoteBase
            
            
            if segue.identifier == "showNoteEntriesSegue" {
                
                let destinationNavController = segue.destinationViewController as! UINavigationController
                let destinationVC = destinationNavController.topViewController as? noteEntriesTableViewController
                destinationVC!.noteBaseRecord = noteBaseRecord as NoteBase
                destinationVC!.managedObjectContext = managedObjectContext

            } else if segue.identifier == "modifyNoteTitle" {
                
                let destinationNavController = segue.destinationViewController as! UINavigationController
                let destinationVC = destinationNavController.topViewController as? TitleEntryViewController
                destinationVC!.newTitleRequest = false
                destinationVC!.noteBaseRecord = noteBaseRecord as NoteBase
                destinationVC!.managedObjectContext = managedObjectContext
           }
        }
        
    }
    
    
    //  All data update functions moved to TitleEntryViewController
    @IBAction func unwindFromTitleEntry(sender: UIStoryboardSegue) {
        
      tableView.reloadData()
    }
    
    
    
    func getManagedContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext!
    }
    
    
/*
    // Preserve/restore state data if interrupted
    override func encodeRestorableStateWithCoder(coder: NSCoder) {
        //1
        coder.encodeObject(noteCreateDate, forKey: "noteCreateDate")
        coder.encodeObject(noteTitle, forKey: "noteTitle")
//        coder.encodeObject(record, forKey: "noteBaseRecord")
        coder.encodeObject(managedObjectContext, forKey: "MOC")
     
        //2
        super.encodeRestorableStateWithCoder(coder)
    }
    
    override func decodeRestorableStateWithCoder(coder: NSCoder) {


        managedObjectContext = coder.decodeObjectForKey("MOC") as! NSManagedObjectContext!
        noteCreateDate = coder.decodeObjectForKey("noteCreateDate") as! NSDate!
        noteTitle = coder.decodeObjectForKey("noteTitle") as! String!
 //       record = coder.decodeObjectForKey("noteBaseRecord") as! NSManagedObject!
     
        super.decodeRestorableStateWithCoder(coder)
    }
 
     override func applicationFinishedRestoringState() {
        NSLog("called applicationFinishedRestoringState")
//        performSegueWithIdentifier("mySegue", sender: self)

        
    }
    */
    
    // Mark - end of NoteBaseTableController class definition
}
 
