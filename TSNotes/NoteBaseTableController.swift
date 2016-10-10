
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
    
    var noteCreateDate = Date()
    var noteTitle = String()

    var noteBaseRecord: NoteBase!

    var currentIndexPath: IndexPath?
    
    var titleString = ""
    var segueListNoteInstance : NoteBase!
    
    var selectedCreateDate = Date()
    
    let dayTimePeriodFormatter = DateFormatter()
    
    // dayTimePeriodFormatter.dateFormat = "EEEE, d MMMM yyyy h:m a"


    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        dayTimePeriodFormatter.dateFormat =  "EEEE MM/d/yy    h:mm a"
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem
        
        
        // Show location of database
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        print("App Path: \(dirPaths)")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
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
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [AnyHashable: Any]?) -> Bool {
        // Override point for customization before application launch.
        
        //      let appState = application.applicationState
        
         return true
         }
 
        
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any]?) -> Bool {
        
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
//    lazy var fetchedResultsController: NSFetchedResultsController = { () -> <<error type>> in
    lazy var fetchedResultsController: NSFetchedResultsController = { () -> <<error type>>
        
        
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

    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
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
                let cell = tableView.cellForRow(at: indexPath) as! noteListTableViewCell
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
            break;
        }
    }
    
    func configureCell(_ cell: noteListTableViewCell, atIndexPath indexPath: IndexPath) {
        
        noteBaseRecord = fetchedResultsController.object(at: indexPath)  as! NoteBase
        
            
        // Update Cell
        if let modifyDateTS = noteBaseRecord.value(forKey: "modifyDateTS") as? Date {
            cell.noteTitleField.text = noteBaseRecord.value(forKey: "noteName") as? String
            cell.noteModifyDate.text = dayTimePeriodFormatter.string(from: modifyDateTS)
        }
        
        if let count = noteBaseRecord.value(forKey: "noteCount") as? Int {
            cell.noteCount.text = String(count)            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        let alertController = UIAlertController(title: "TS Notes", message: "Recieved a memory warning", preferredStyle: UIAlertControllerStyle.alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
    
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        // return the number of rows
        if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteListTableViewCell", for: indexPath)
            as! noteListTableViewCell

        // Configure Table View Cell
        configureCell(cell, atIndexPath: indexPath)
        
    return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        
        return true
    }


    // Enable row deletes
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
 
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {

        return ""
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
 
        
        // This is to restore the color scheme to the cell after selection
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        do {
            try self.managedObjectContext.save()
        } catch {
            let saveError = error as NSError
            print("\(saveError), \(saveError.userInfo)")
        }
    }
    
    
    // Navigation
    @IBAction func cancelButton(_ sender: AnyObject) {
        
        if let navController = self.navigationController {
            navController.popViewController(animated: true)

        }else{
            
            print("optional value")
        }
    }
    

    //Set up row edit actions
    
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
                
                do {
                    try self.managedObjectContext.save()
                    //5
                } catch let error as NSError  {
                    print("Could not save \(error), \(error.userInfo)")
                }

            })
            
            alertController.addAction(deleteAction)
            
            
            self.present(alertController, animated: true, completion: nil)
    
            
        }
        
        deleteChoice.backgroundColor = UIColor.red
        
        
        let editChoice = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            print("edit button tapped")
            self.currentIndexPath = indexPath
            self.performSegue(withIdentifier: "modifyNoteTitle", sender: self)
            tableView.reloadRows (at: [indexPath], with: UITableViewRowAnimation.automatic)

        }
        
        editChoice.backgroundColor = UIColor.gray
        
        return [editChoice, deleteChoice]
    }
    
    /*
    override func tableView(tableView: UITableView,editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?  {
     
    }

    */
    // MARK: - Actions
    
    // Edit button action
    @IBAction func editButtonClicked(_ sender: AnyObject) {
        NSLog("edit button was clicked", 4)
    }

    
    // MARK: - Navigation
    
    
    // segue to noteEntriesTableViewController or TitleEntryViewController
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        

        // If we're adding a new note
        if segue.identifier == "AddnoteTitleField" {
            
            let destinationNavController = segue.destination as! UINavigationController
            let destinationVC = destinationNavController.topViewController as? TitleEntryViewController
            
            let entity =  NSEntityDescription.entity(forEntityName: "NoteBase", in:managedObjectContext)
            noteBaseRecord = NSManagedObject(entity: entity!, insertInto: managedObjectContext) as! NoteBase
            
            destinationVC!.newTitleRequest = true
            destinationVC!.managedObjectContext = managedObjectContext
            destinationVC!.noteBaseRecord = noteBaseRecord
            
    } else {

            // we're showing the note entries or we're changing the note title
            
            // Fetch current base record
            let indexPath = tableView.indexPathForSelectedRow
            let usableIndexPath = (indexPath ?? currentIndexPath)
            
            noteBaseRecord = fetchedResultsController.object(at: usableIndexPath!) as! NoteBase
            
            
            if segue.identifier == "showNoteEntriesSegue" {
                
                let destinationNavController = segue.destination as! UINavigationController
                let destinationVC = destinationNavController.topViewController as? noteEntriesTableViewController
                destinationVC!.noteBaseRecord = noteBaseRecord as NoteBase
                destinationVC!.managedObjectContext = managedObjectContext

            } else if segue.identifier == "modifyNoteTitle" {
                
                let destinationNavController = segue.destination as! UINavigationController
                let destinationVC = destinationNavController.topViewController as? TitleEntryViewController
                destinationVC!.newTitleRequest = false
                destinationVC!.noteBaseRecord = noteBaseRecord as NoteBase
                destinationVC!.managedObjectContext = managedObjectContext
           }
        }
        
    }
    
    
    //  All data update functions moved to TitleEntryViewController
    @IBAction func unwindFromTitleEntry(_ sender: UIStoryboardSegue) {
        
      tableView.reloadData()
    }
    
    
    
    func getManagedContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
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
 
