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
    
//    @IBOutlet weak var tableView: UITableView!
    
    var managedObjectContext: NSManagedObjectContext!
    
    var NoteBase = [TSNoteBaseClass]()
    
    var savedNoteBase = [NSManagedObject]()

    var currentIndexPath: NSIndexPath?
    
    var titleString = ""
    var segueListNoteInstance = TSNoteBaseClass()
    
    var selectedCreateDate = NSDate()
    
    let dayTimePeriodFormatter = NSDateFormatter()
    
    // dayTimePeriodFormatter.dateFormat = "EEEE, d MMMM yyyy h:m a"


    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        dayTimePeriodFormatter.dateFormat =  "EEEE MM/d/yy h:mm a"
        
        //loadSampleNotes()
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem()
        
        // try fetchcontroller fetch
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
        
        // Show location of database
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        print("App Path: \(dirPaths)")
        
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
        // Fetch Record
        let record = fetchedResultsController.objectAtIndexPath(indexPath)
        
        // Update Cell
        if let modifyDateTS = record.valueForKey("modifyDateTS") as? NSDate {
            cell.noteTitleField.text = record.valueForKey("noteName") as? String
            cell.noteModifyDate.text = dayTimePeriodFormatter.stringFromDate(modifyDateTS)
        }
        
        if let count = record.valueForKey("noteCount") as? Int {
            cell.noteCount.text = String(count)            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

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
        if (editingStyle == .Delete) {
         
            /*  LOGIC MOVED to editActionsForRowAtIndexPath 3/10/16
            // Fetch Record
            let record = fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
            
            // Delete Record
            managedObjectContext.deleteObject(record)
                        
            do {
                try managedObjectContext.save()
                //5
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
            */
        }
    }
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        // Set name of note
        //   return noteName
        
        //   let noteModDate = noteEntriesSeparated [section][0].modifyDateTime
        //   let modDateStr = displayDateOnlyFormatter.stringFromDate(noteModDate)
        return ""
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
 
        
        NSLog("Selected section is: \(indexPath.section) and row is: \(indexPath.row)")
 //       NSLog("Cell text is: \(noteEntry.noteText)")
        
        
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
        
        let deleteChoice = UITableViewRowAction(style: .Normal, title: "Delete") { action, index in
            print("delete button tapped")
            
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

        }
        deleteChoice.backgroundColor = UIColor.redColor()
        
        let editChoice = UITableViewRowAction(style: .Normal, title: "Edit") { action, index in
            print("edit button tapped")
            self.currentIndexPath = indexPath
            self.performSegueWithIdentifier("modifyNoteTitle", sender: self)
        }
        editChoice.backgroundColor = UIColor.grayColor()
        
        return [editChoice, deleteChoice]
    }
    
    /*
    override func tableView(tableView: UITableView,editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?  {
     
        // 1
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Edit" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            
            
            // 2
            
            // 1
            let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Edit" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
                // 2
                
                self.performSegueWithIdentifier("modifyNoteName", sender: self)
            })
            
            
//            self.presentViewController(editMenu, animated: true, completion: nil)
        })
       
        // 2
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            // 2
            let editMenu = UIAlertController(title: nil, message: "Delete", preferredStyle: .ActionSheet)
            
            let editAction = UIAlertAction(title: "Edit", style: UIAlertActionStyle.Default, handler: nil)
            
            editMenu.addAction(editAction)
            
            
            self.presentViewController(editMenu, animated: true, completion: nil)
        })
        
        /*
        // 3
        var rateAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Rate" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            // 4
            let rateMenu = UIAlertController(title: nil, message: "Rate this App", preferredStyle: .ActionSheet)
            
            let appRateAction = UIAlertAction(title: "Rate", style: UIAlertActionStyle.Default, handler: nil)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            
            rateMenu.addAction(appRateAction)
            rateMenu.addAction(cancelAction)
            
            
            self.presentViewController(rateMenu, animated: true, completion: nil)
        })
        */
        
        // 5
        return [deleteAction,editAction]
    }

    */
    // MARK: - Actions
    
    // Edit button action
    @IBAction func editButtonClicked(sender: AnyObject) {
        NSLog("edit button was clicked", 4)
    }

    
    // MARK: - Navigation
    
    
    // segue to noteEntriesTableViewController
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        // If we're adding a new note
        if segue.identifier == "AddnoteTitleField" {
            
            let destinationNavController = segue.destinationViewController as! UINavigationController
            let destinationVC = destinationNavController.topViewController as? TitleEntryViewController
            destinationVC!.newTitleRequest = true
            
    } else {

            // we're showing the note entries or we're changing the note title
            
            // Fetch Record
            
            let indexPath = tableView.indexPathForSelectedRow
                
            let usableIndexPath = (indexPath ?? currentIndexPath)
            let record = fetchedResultsController.objectAtIndexPath(usableIndexPath!) as! NSManagedObject
            
            // Configure View Controller
            let noteCreateDate = (record.valueForKey("createDateTS") as? NSDate)!
            let noteTitle = (record.valueForKey("noteName") as! String)
        
            
            if segue.identifier == "showNoteEntriesSegue" {
                
                let destinationNavController = segue.destinationViewController as! UINavigationController
                let destinationVC = destinationNavController.topViewController as? noteEntriesTableViewController
                destinationVC!.noteCreateDate = noteCreateDate
                destinationVC!.noteName = noteTitle
                destinationVC!.noteBaseRecord = record
                destinationVC!.managedObjectContext = managedObjectContext

            } else if segue.identifier == "modifyNoteTitle" {
                
                let destinationNavController = segue.destinationViewController as! UINavigationController
                let destinationVC = destinationNavController.topViewController as? TitleEntryViewController
                destinationVC!.noteCreateDate = noteCreateDate
                destinationVC!.noteTitleField = noteTitle
                destinationVC!.newTitleRequest = false
            }
        }
    }
    
    
    
    
    
    @IBAction func unwindToTitleEntry(sender: UIStoryboardSegue) {
        
         let sourceViewController = sender.sourceViewController as? TitleEntryViewController,
            segueListNoteInstance = sourceViewController!.segueListNoteInstance
 
        saveNote(segueListNoteInstance, boolNewNote:  sourceViewController?.newTitleRequest)
        tableView.reloadData()
        

        
    }
    
    func saveNote(newNoteInfo: TSNoteBaseClass, boolNewNote: Bool?) {
        
        let moc = getManagedContext()
       
        //2

        let entity =  NSEntityDescription.entityForName("NoteBase", inManagedObjectContext:moc)
        let noteHeader = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: moc)
        
        //3
           
        noteHeader.setValue(newNoteInfo.modifyDateTime, forKey: "modifyDateTS")
        noteHeader.setValue(newNoteInfo.createDateTime, forKey: "createDateTS")
        noteHeader.setValue(newNoteInfo.noteTitleField, forKey: "noteName")
        
        //4
        do {
            try moc.save()
            //5
            if boolNewNote! {
                savedNoteBase.append(noteHeader)
            }
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
    }
    
    
    func getManagedContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext!
    }


}
