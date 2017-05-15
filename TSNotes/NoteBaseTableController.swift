
//
//  NoteBaseTableController.swift - this is the table listing all the notes
//  TSNotes
//
//  Created by Jeanne's MacBook on 11/6/15.
//  Copyright © 2015 LCI. All rights reserved.
//

import UIKit
import CoreData

    // 2/12/17 temporarily removing UISearchResultsUpdating, , UISearchBarDelegate until I better understand searching
class NoteBaseTableController: UITableViewController, UISearchResultsUpdating,UISearchBarDelegate, NSFetchedResultsControllerDelegate   {
    
    // MARK: Properties
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableHeader: UIView!
    @IBOutlet weak var edtButton: UIBarButtonItem!
    
    // Properties for search function
    var searchController = UISearchController()
    var filteredNotes = [String]()
    
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
        
            //return
                
                
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.definesPresentationContext = true
        
        searchController.searchBar.sizeToFit()
        
/*        DispatchQueue.main.async {
            let offset = CGPoint.init(x: 0, y: self.searchBar.bounds.height)
            self.tableView.setContentOffset(offset, animated: false)
        }
*/ 
        //toggleHeader()
//        tableView.tableHeaderView = nil   // table header doesn't show
//        bSearchFieldShowing = false
        
        // Initialize core data elements
        if managedObjectContext == nil {
            managedObjectContext = getManagedContext ()
            if managedObjectContext == nil {
                print("managedObjectContext has nil value")
                //exit(0)
            }
            
            initializeFetchRequest()
        }
        
        // Someone's idea about how to implement pull down search function
        


        // Initialize the refresh control
        searchController.searchResultsUpdater = self as UISearchResultsUpdating
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = searchController.searchBar
        self.tableView.contentOffset = CGPoint(x:0, y:searchController.searchBar.frame.height);

        

        // Someone;s idea of how to handle pull down search field
       // tableView.scrollToRow(at: NSIndexPath(row: 0, section: 0) as IndexPath, at: <#T##UITableViewScrollPosition#>, animated: false)
        //tableView.tableHeaderView = searchController.searchBar
        
        /*
         // Set up fetchedResultsController and default fetchRequest
        initializeFetchRequest()
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem
        tableView.contentOffset = CGPoint(x:0, y:searchBar.frame.size.height)
*/
    }
    
    override func viewWillAppear(_ animated: Bool)  {
        
        let searchBarFrameSize = searchBar.frame.size.height
        print("\n\nSearchbar height: \(searchBarFrameSize)\n\n")
        
        /*
        // initialize search controller after the core data
        self.resultSearchController.searchResultsUpdater = self
        self.resultSearchController.dimsBackgroundDuringPresentation = false
        self.resultSearchController.searchBar.sizeToFit()
        
        
        // places the built-in searchbar into the header of the table
        self.tableView.tableHeaderView = self.resultSearchController.searchBar
        
        // makes the searchbar stay in the current screen and not spill into the next screen
        definesPresentationContext = true
         
         */
        
        
        super.viewWillAppear(animated);
        
        
        
        // try fetchcontroller fetch
        fetchRecords()

    }

    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [AnyHashable: Any]?) -> Bool {
        // Override point for customization before application launch.
        
        //      let appState = application.applicationState
        
         return true
         }
 
        
    /*
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any]?) -> Bool {
        
        // try fetchcontroller fetch
        do {
//            let request: NSFetchRequest<NoteBase> = NoteBase.fetchRequest() as! NSFetchRequest<NoteBase>
        //    try self.fetchedResultsController.  //.performFetch()
        fetch()
            
        /*
        try self.fetchedResultsController.performFetch()

        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
        */

        return true
            
        }
    }
    */
    

    /*
    // Initialize fetchedResultsController
    
 //   lazy var fetchedResultsController: NSFetchedResultsController<NoteBase> = {
        
        
        // Initialize Fetch Request
      //  let fetchRequest = NSFetchRequest(entityName: "NoteBase")
        //let fetchRequest: NSFetchRequest<NoteBase> = NoteBase.fetchRequest() as! NSFetchRequest<NoteBase>
        
        // Add Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: "modifyDateTS", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Initialize Fetched Results Controller
        //let
 //       fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
 //   }()
 
        */

    
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
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest as! NSFetchRequest<Note> as! NSFetchRequest<NoteBase>, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self as? NSFetchedResultsControllerDelegate
        
    }
    
    
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
    
    
    
    
    
    /*
    override func tableView(tableView: UITableView,editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?  {
     
    }

    */
    
    
    // MARK: - Implement pull down search
    



/*
    override func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat{
        return 50
    }
*/
    
/*
    override func scrollViewDidScroll(_ scrollView: UIScrollView){
        if(scrollView.contentOffset.y < 0) {
            toggleHeader()
        }
    }
*/
    
    func refresh(sender:AnyObject)
    {
        //Load Data
        
    }
    
    
    // MARK: - Actions
    
    // Edit button action
    @IBAction func editButtonClicked(_ sender: AnyObject) {
        NSLog("edit button was clicked", 4)
    }
    
   


    // Mark: - implement search controller functions
    public func updateSearchResults(for searchController: UISearchController) {
        
        // process the search string, remove leading and trailing spaces
        let searchText = searchController.searchBar.text! as NSString
        let trimmedSearchString = searchText.trimmingCharacters(in: NSCharacterSet.whitespaces)
        
        // if search string is not blank
        if !trimmedSearchString.isEmpty {
            
            // form the search format
            let predicate = NSPredicate(format: "(noteName contains [cd] %@)", trimmedSearchString)
            
            // add the search filter
            fetchedResultsController.fetchRequest.predicate = predicate
        }
/*
        else {
            
            // reset to all patients if search string is blank
            //fetchedResultsController ()           // frc = getFRC()
        }
        
        // reload the frc
        fetch()
        
        // refresh the table view
        self.tableView.reloadData()
*/
        
        }
    
 
   
   
/*
    func setFetchRequest(searchString : String ) -> NSFetchRequest<NSFetchRequestResult> {
        
         fetchRequest = NSFetchRequest(NoteBase) = NoteBase.fetchRequest() as! NSFetchRequest<NoteBase>
        //fetchRequest = NSFetchRequest(entityName: "Patient")
        return fetchRequest as! NSFetchRequest<NSFetchRequestResult>
    }
    
*/
    
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
    

/*
    // updates the table view with the search results as user is typing...
    func updateSearchResults(for searchController: UISearchController) {
        
        // process the search string, remove leading and trailing spaces
        let searchText = searchController.searchBar.text!
        let trimmedSearchString = searchText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        // if search string is not blank
        if !trimmedSearchString.isEmpty {
            
            // form the search format
            fetchPredicate = NSPredicate(format: "(name contains [cd] %@)", trimmedSearchString)
        }
        else {
            
            // reset to all notes if search string is blank
            fetchPredicate = nil
       }
        
        
        // add the search filter
        fetchRequest.predicate = fetchPredicate
        
        // reload the frc
        fetchRecords()
        
        // refresh the table view
        self.tableView.reloadData()
    }
 
*/


    
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
                    
                } else {
                    
                    // indicate search
                    destinationVC!.bSearchEntries = true
                }
                
            }

        }
        
    }
    
    
    //  All data update functions moved to TitleEntryViewController
    @IBAction func unwindFromTitleEntry(_ sender: UIStoryboardSegue) {
        
       tableView.reloadData()
    }
    


    // Collections of code not used at present
/*
        // This is code to support a search bar but I want to use a pulldonw
 
     // Implement search function
     func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
     searchActive = true;
     }
     
     func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
     searchActive = false;
     }
     
     func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
     searchActive = false;
     }
     
     func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
     searchActive = false;
     }
     
     func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
     
     
     filtered = data.filter({ (text) -> Bool in
     let tmp: NSString = text as NSString
     let range = tmp.range(of: searchText, options:NSString.CompareOptions.caseInsensitive)
     return range.location != NSNotFound
     })
     
     
     
     if(filtered.count == 0){
     searchActive = false;
     } else {
     searchActive = true;
     }
     self.tableView.reloadData()
     //self.tableView.contentOffset = CGPoint(x:0, y:self.searchBar.frame.size.height);
     }
     
     
*/
    
    
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
 
