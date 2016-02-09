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
    
    let cellIdentifier = "noteListTableViewCell"
//    let ReuseIdentifierNoteListCell = "noteListTableViewCell"
    
//    @IBOutlet weak var tableView: UITableView!
    
    var managedObjectContext: NSManagedObjectContext!
    
    var NoteBase = [TSNoteBaseClass]()
    
    var savedNoteBase = [NSManagedObject]()
    
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

        dayTimePeriodFormatter.dateFormat =  "h:mm a  d MM yyyy - EEEE"
        
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
            cell.noteTitle.text = record.valueForKey("noteName") as? String
            cell.noteModifyDate.text = dayTimePeriodFormatter.stringFromDate(modifyDateTS)
        }
        
        if let count = record.valueForKey("noteCount") as? Int {
            cell.noteCount.text = "\(count)"
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        
        /*
        //2
        
        let moc = getManagedContext()

        let fetchRequest = NSFetchRequest(entityName: "NoteBase")
        
        // Add Sort Descriptor
        let sortDescriptor = NSSortDescriptor(key: "modifyDateTS", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        
        //3
        do {
            let results =
            try moc.executeFetchRequest(fetchRequest)
            savedNoteBase = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        */
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
        
        return 0   }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
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


    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        
        let moc = getManagedContext()

        
        if editingStyle == .Delete {
            
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
         //   let NoteBase = savedNoteBase[indexPath.row]
            
         //   moc.deleteObject(NoteBase)
            
            do {
                try moc.save()
            } catch {
                let saveError = error as NSError
                print(saveError)
            }

            savedNoteBase.removeAtIndex(indexPath.row)
            
            tableView.reloadData()

        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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
 
        /*
        NSLog("Selected section is: \(indexPath.section) and row is: \(indexPath.row)")
        let noteEntry = noteEntriesSeparated [indexPath.section][indexPath.row]
        NSLog("Cell text is: \(noteEntry.noteText)")
        */
        
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
    


    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation
    
    
    // segue to noteEntriesTableViewController
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "showNoteEntriesSegue" {
            
        
            if let destinationVC = segue.destinationViewController as? noteEntriesTableViewController{
                    if let indexPath = tableView.indexPathForSelectedRow {
                        // Fetch Record
                        let record = fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
                        
                        // Configure View Controller
                        destinationVC.noteCreateDate = (record.valueForKey("createDateTS") as? NSDate)!
                        destinationVC.noteName = (record.valueForKey("noteName") as! String)
                        destinationVC.noteBaseRecord = record
                        destinationVC.managedObjectContext = managedObjectContext
                    }
            }
            //    }

          //  }
        }
    }
    
    
    
    
    @IBAction func unwindToTitleEntry(sender: UIStoryboardSegue) {
        
         let sourceViewController = sender.sourceViewController as? TitleEntryViewController,
            segueListNoteInstance = sourceViewController!.segueListNoteInstance
 
   //             NSLog("numberOfRowsInSection: \(tableView.numberOfRowsInSection(0))")
        
        
        saveNote(segueListNoteInstance)
        tableView.reloadData()
        

        
    }
    
    func saveNote(newNoteInfo: TSNoteBaseClass) {
        //1
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        let managedContext = appDelegate.managedObjectContext
        
        let moc = getManagedContext()
       
        //2

        let entity =  NSEntityDescription.entityForName("NoteBase",
            inManagedObjectContext:moc)
        
        let noteHeader = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext: moc)
        
        //3
        
        
        noteHeader.setValue(newNoteInfo.modifyDateTime, forKey: "modifyDateTS")
        noteHeader.setValue(newNoteInfo.createDateTime, forKey: "createDateTS")
        noteHeader.setValue(newNoteInfo.noteTitle, forKey: "noteName")
        
        //4
        do {
            try moc.save()
            //5
            savedNoteBase.append(noteHeader)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
    }
    
    
    func getManagedContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext!
    }


}
