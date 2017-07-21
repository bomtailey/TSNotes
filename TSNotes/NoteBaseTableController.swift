//
//  NoteBaseTableController.swift - this is the table listing all the notes
//  TSNotes
//
//  Created by Jeanne's MacBook on 11/6/15.
//  Copyright © 2015 LCI. All rights reserved.
//

import UIKit
import CoreData

    // 2/12/17 temporarily removing UISearchResultsUpdating, , UISearchBarDelegate
    //   UISearchResultsUpdating,UISearchBarDelegate,       until I better understand searching

class NoteBaseTableController: UITableViewController,  NSFetchedResultsControllerDelegate, UISearchBarDelegate   {
    
    // MARK: UI connections
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableHeader: UIView!
    @IBOutlet weak var edtButton: UIBarButtonItem!
    
    // MARK: Local variables
    
    // Properties for search function
   // var searchController = UISearchController()
    var searchString = String()
    
    // Properties for core data functions
    var managedObjectContext: NSManagedObjectContext!
    var fetchedResultsController: NSFetchedResultsController<NoteBase> = NSFetchedResultsController()
    var fetchRequest: NSFetchRequest<NoteBase> = NoteBase.fetchRequest() as! NSFetchRequest<NoteBase>
    var fetchPredicate: NSPredicate?
    
    
    var noteCreateDate = Date()
    var noteTitle = String()

    var noteBaseRecord: NoteBase!

    var currentIndexPath: IndexPath?
    
    var titleString = ""
    var segueListNoteInstance : NoteBase!
    
    var selectedCreateDate = Date()
    
    let dayTimePeriodFormatter = DateFormatter()
    var bSearchFieldShowing = Bool(false)
    
    var tapGestureRecognizer : UITapGestureRecognizer!

    
    
    // dayTimePeriodFormatter.dateFormat = "EEEE, d MMMM yyyy h:m a"

    // MARK: - code segments

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        // Show location of database
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        print("\n\nDatabase Path: \(dirPaths)\n\n")
        

        // Uncomment the following line to preserve selection between presentations
         //self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        dayTimePeriodFormatter.dateFormat =  "EEEE MM/d/yy    h:mm a"
        
        tableView.tableHeaderView = searchBar
        self.searchBar.delegate = self

/*        var contentOffset: CGPoint = self.tableView.contentOffset
        contentOffset.y += (self.tableView.tableHeaderView?.frame)!.height
        self.tableView.contentOffset = contentOffset
*/
        tableView.contentOffset = CGPoint(x:0, y:searchBar.frame.height);

        
        
        // This implements tap/double tap on the navigation bar to scroll the list to the top or bottom
        let singleTap = UITapGestureRecognizer(target: self, action:#selector(self.singleTapAction(_:)))
        singleTap.numberOfTapsRequired = 1
        self.navigationController?.navigationBar.addGestureRecognizer(singleTap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action:#selector(self.doubleTapAction(_:)))
        doubleTap.numberOfTapsRequired = 2
        self.navigationController?.navigationBar.addGestureRecognizer(doubleTap)
        
        // This effects discrimination of single/double tap
        singleTap.require(toFail: doubleTap)
        


        
        // Initialize core data elements
        if managedObjectContext == nil {
            managedObjectContext = getManagedContext ()
            if managedObjectContext == nil {
                print("managedObjectContext has nil value")
                //exit(0)
            }
            
            initializeFetchRequest()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool)  {
        
        
        super.viewWillAppear(animated);
 
        
        // try fetchcontroller fetch
        fetchRecords()
        

    }

    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [AnyHashable: Any]?) -> Bool {
        // Override point for customization before application launch.
        
        //      let appState = application.applicationState
        
         return true
         }
 
        

    
    // MARK: - core data actions
    
    
    func getManagedContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.managedObjectContext!
    }

    // Initialize fetchedResultsController
    func initializeFetchRequest() {
        
        
        // Initialize fetch request
        fetchRequest = NSFetchRequest(entityName: "NoteBase")
        
        // Add Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: "modifyDateTS", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Initialize Fetched Results Controller
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self as NSFetchedResultsControllerDelegate
        
    }
    
    
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
        
        noteBaseRecord = fetchedResultsController.object(at: indexPath)  
                    
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
           // self.tableView.contentOffset = CGPoint(x:0, y:self.searchBar.frame.size.height);
        })
        
        alertController.addAction(cancelAction)

        
        let deleteChoice = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            //print("delete button tapped")
            
            let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: {(alert :UIAlertAction!) in
               // print("Delete button tapped")
                
                // Fetch Record
                let record = self.fetchedResultsController.object(at: indexPath) as NSManagedObject
                
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
       //     print("edit button tapped")
            self.currentIndexPath = indexPath
            self.performSegue(withIdentifier: "modifyNoteTitle", sender: self)
            tableView.reloadRows (at: [indexPath], with: UITableViewRowAnimation.automatic)
            //self.tableView.contentOffset = CGPoint(x:0, y:self.searchBar.frame.size.height);

        }
        
        editChoice.backgroundColor = UIColor.gray
        
        return [editChoice, deleteChoice]
    }
    
    
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
         searchString = searchBar.text!
         performSegue(withIdentifier: "searchNotesSegue", sender: self)
    }


    
    func refresh(sender:AnyObject)
    {
        //Load Data
        
    }
    
    
    // MARK: - Actions
    
    // Edit button action
    @IBAction func editButtonClicked(_ sender: AnyObject) {
        NSLog("edit button was clicked", 4)
    }
    
    
 
    
    // update the contents of the fetch results controller
    func fetchRecords() {
        
        // try fetchcontroller fetch
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
    }
    
    
    // MARK: - handle navigation bar taps to scroll list:
    
    //  1 tap to top, 2 to bottom.  These functions set up with addGestureRecognizer in ViewWillAppear
    
    // Handle navigation bar single tap - scroll to the top
    func singleTapAction (_ theObject: AnyObject) {
        
        if theObject.state == .ended {
            let indexPath = NSIndexPath(row: 0, section: 0)
            self.tableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
        }
        
        // let sbHeight = searchBar.frame.height
        tableView.contentOffset = CGPoint(x:0, y:searchBar.frame.height);

    }
    
    // Handle navigation bar double tap - scroll to the bottom
    func doubleTapAction (_ theObject: AnyObject) {
        
        if theObject.state == .ended {
            let numRows = tableView( tableView, numberOfRowsInSection: 0) - 1
            let indexPath = NSIndexPath(row: numRows, section: 0)
            self.tableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
        }
        
        // let sbHeight = searchBar.frame.height
        tableView.contentOffset = CGPoint(x:0, y:searchBar.frame.height);

    }

    

    
    // MARK: - Navigation
    
    
    // segue to noteEntriesTableViewController or TitleEntryViewController
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        

        // If we're adding a new note
        if segue.identifier == "AddnoteTitleField" {
            
            let destinationNavController = segue.destination as! UINavigationController
            let destinationVC = destinationNavController.topViewController as? TitleEntryViewController
            
   //         let entity =  NSEntityDescription.entity(forEntityName: "NoteBase", in:managedObjectContext)
   //         noteBaseRecord = NSManagedObject(entity: entity!, insertInto: managedObjectContext) as! NoteBase
            
            destinationVC!.newTitleRequest = true
            destinationVC!.managedObjectContext = managedObjectContext
   //         destinationVC!.noteBaseRecord = noteBaseRecord
            
    } else {

            // 2/15/17 - revised for searching note entries, we're either
            // a) showing the note entries or 
            // b) we're changing the note title or
            // c) we're searching note entries
            
            // Fetch current base record
            let indexPath = tableView.indexPathForSelectedRow
            let usableIndexPath = (indexPath ?? currentIndexPath)
            
            
            if segue.identifier == "modifyNoteTitle" {
                
                noteBaseRecord = fetchedResultsController.object(at: usableIndexPath!)
                let destinationNavController = segue.destination as! UINavigationController
                let destinationVC = destinationNavController.topViewController as? TitleEntryViewController
                destinationVC!.newTitleRequest = false
                destinationVC!.noteBaseRecord = noteBaseRecord as NoteBase
                destinationVC!.managedObjectContext = managedObjectContext
                
            } else  {
                
                // note entries
                let destinationNavController = segue.destination as! UINavigationController
                let destinationVC = destinationNavController.topViewController as? noteEntriesTableViewController
                destinationVC!.managedObjectContext = managedObjectContext
                
                if segue.identifier == "showNoteEntriesSegue" {
                
                    noteBaseRecord = fetchedResultsController.object(at: usableIndexPath!)
                    destinationVC!.noteBaseRecord = noteBaseRecord as NoteBase
                    destinationVC!.bSearchEntries = false
                    
                } else { if segue.identifier == "searchNotesSegue" {
                    
                    
                    // indicate search
                    destinationVC!.bSearchEntries = true
                    destinationVC!.searchString = searchString
                   }

                }
                
            }

        }
        
    }
    
    
    //  All data update functions moved to TitleEntryViewController
    @IBAction func unwindFromTitleEntry(_ sender: UIStoryboardSegue) {
        
       tableView.reloadData()
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
 
