 //
//  noteEntriesTableViewController.swift - This is the table giving the entries for a particular note
/*
 
  ==> 8/16/17 For search display, we need to redo search if edit or add of entries produces new hits.  
        Also need to implement search on note entries display
  
  ==> 7/7/17 For search display, need to get reference to NoteBase record for updates
                Also, section header (mod date) is screwy
    ==> 5/15/17 Add search notes capability
         - we're now going to receive control in 2 cirmcumstances:
            - as the existing request to display the entries for a particular note
            - a request to search the entire collection of notes

    Created by Jeanne's MacBook on 11/12/15.
    Copyright © 2015 LCI. All rights reserved.
*/

import UIKit
import CoreData

class noteEntriesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchBarDelegate {
    
    // searchbar from storyboard
    @IBOutlet weak var searchBar: UISearchBar!
    
    // Properties
    // named views so we can pass touch through to tablecll
    
    // MARK: - define variables - local
    
    // Properties for search function
    var resultSearchController = UISearchController()
    var fetchPredicate: NSPredicate?

    // Properties for core data functions
    var fetchedResultsController: NSFetchedResultsController<Note> = NSFetchedResultsController()
    var notesFetchRequest: NSFetchRequest<Note> = Note.fetchRequest() as! NSFetchRequest<Note>
    var sortDescriptor = NSSortDescriptor(key: "noteModifiedDateTS", ascending: false)

    var baseFetchedResultsController: NSFetchedResultsController<NoteBase> = NSFetchedResultsController()
    var baseFetchRequest: NSFetchRequest<NoteBase> = NoteBase.fetchRequest() as! NSFetchRequest<NoteBase>
    var bNewFetch = Bool(false)
    
    // MARK: - variables from NoteBaseTableController
    var managedObjectContext: NSManagedObjectContext!
    var noteBaseRecord: NoteBase!
    var bSearchEntries = Bool(false)
    var searchString: String?

    
    // MARK: - local variables
    
    var noteName = String()
    var noteCreateDate = Date()
    var statusText = String()
    var bNewNote = true
    var noteRecord = Note()
    var bIsRestore = true
    var myViewController = UIViewController()
    var currentCell: TSNoteEntriesTableCell!
    
    var lineStyle = NSMutableParagraphStyle()

    
    let displayDateFormatter = DateFormatter()
    let sortableDateOnlyFormatter = DateFormatter()
    let displayDateOnlyFormatter = DateFormatter()
    let displayTimeOnlyFormatter = DateFormatter()
    
    // Temporary debug vars
    var sectionName = String()
//    var noteText = String()
//    var noteModDateTime = Date()
    
    // MARK: - variables associated with search

    var cellText = String()
    var myMutableString = NSMutableAttributedString()
    let myAttribute = [ NSFontAttributeName: UIFont(name: "Papyrus", size: 16.0)! ]
 
    var wordCollection = [(String())]
    var firstSearchTerm: String?
    var predicateArray = [NSPredicate]()
    var datedNotesPredicate = NSPredicate()
    var tableEntriescount = Int(0)
    var matchCount = Int(0)
    var recordNum = Int(0)
    var objectRecordPtr = [[Int]]()
   // var matchLocations: [String.Index] = []
    //var matchArray = [[tempRange]()]
    var firstMatchLocArray = [NSRange]()
    var mutableRecordsArray = [NSMutableAttributedString]()
    var xferVar = NSMutableAttributedString()
    var sectionNameArray = [String]()
    var currentBaseRecord: NoteBase!

    // MARK: - Code section
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
       // MARK - 2/15/17 right off the bat we need to decide if we've been called to search or
        //   provide a normal display.  Perhaps we should separate the search function in its own
        //   controller and display
        
       
        displayDateFormatter.dateFormat = "h:mm a  EEEE, MMMM d, yyyy"
        sortableDateOnlyFormatter.dateFormat = "yyyy.MM.dd"
        displayDateOnlyFormatter.dateFormat = "EEEE MMMM, d yyyy"  // "EEEE, d MMMM yyyy"
        displayTimeOnlyFormatter.dateFormat = "h:mm a"
        
       
//        fetchedResultsController = getFRC() as! NSFetchedResultsController<Note>
        
        // Mark: to implement dynamic row height
 //       tableView.rowHeight = UITableViewAutomaticDimension
 //       tableView.estimatedRowHeight = 60
        
        // Attempt to control line spacing
        //lineStyle.lineSpacing = 24 // change line spacing between paragraph like 36 or 48
        lineStyle.minimumLineHeight = 10 // change line spacing between each line like 30 or 40
        
        // Searchbar 
        tableView.tableHeaderView = searchBar
        self.searchBar.delegate = self
        tableView.contentOffset = CGPoint(x:0, y:searchBar.frame.height);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableEntriescount = 0
        
        if bSearchEntries {
            searchBar.text = searchString
        } else {
            noteName = noteBaseRecord.noteName!
            navigationItem.title = noteName
            tableView.contentOffset = CGPoint(x:0, y:searchBar.frame.height);
        }
       
        
        if bSearchEntries {
            buildPredicate ( searchString: searchString! )
        }

        fetchedResultsController = getFRC() as! NSFetchedResultsController<Note>
        fetchRecords ()
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if bSearchEntries {
            
            // set table title
            setStatusText(queryString: searchString!, count: matchCount)
            navigationItem.title = statusText
        }

//        bNewFetch = false
        
    }
    
    func setStatusText(queryString: String, count: Int)  {
        
        var countType1 = String()
        var countType2 = String()
        
        countType2 = " matches"
        countType1 = " match"
        statusText = searchString! + ": "
        
        if count == 0 {
            statusText = statusText + "no " + countType2
        } else if count == 1 {
            statusText = statusText + "1 " + countType1
        } else {
            statusText = statusText + String(count) + " " + countType2
        }
    }

   
    
    func fetchRecords () {
        

        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
        
       
        if let numHits = fetchedResultsController.fetchedObjects?.count {
            
            recordNum = 0
            matchCount = 0
            currentBaseRecord = nil
            
            objectRecordPtr = Array(repeating: Array(repeating: 0, count: numHits), count: numHits)
            
            for object in fetchedResultsController.fetchedObjects! {
                
                let pos = fetchedResultsController.indexPath(forObject: object)
                objectRecordPtr[(pos?[0])!][(pos?[1])!] = recordNum
                

                // This seems like a hack but to actually get a copy (not just a reference) of
                // myMutableString, you have to instantiate a new object so we do that with xferVar
                
                xferVar = NSMutableAttributedString(string: object.noteText! )
                
             //   NSLog("\n\nIn  fetchRecords, text of record# \(expandedrecordNum + 1) is: \(String(describing: object.noteText!))")
                
                // If we're doing a search, let's count and hightlight the hits.  We'll save them in
                // mutableRecordsArray
                
                if bSearchEntries {
                    
                    // Save note names for section titles
                    if currentBaseRecord != object.notesList {
                        currentBaseRecord = object.notesList
                        sectionNameArray.append(currentBaseRecord.noteName!)
                    }
                    
                        // Highlight (and count) matches
                    let results = countAndHighlightMatchesHelper( stringToFind: searchString!,
                                                                  entireString: xferVar)
                    
                   matchCount += results.matchCount
                    
                    firstMatchLocArray.insert(results.firstFindRange, at: recordNum)

                }
                
                xferVar.addAttributes(myAttribute, range:NSRange(location: 0,length: (xferVar.length)))
                mutableRecordsArray.insert(xferVar, at: recordNum)
                
                if recordNum == 0 {
                    
                    // Take an opportunity to populate noteBaseRecord pointer
                    noteBaseRecord = object.notesList
                }
                
                recordNum += 1

            }

            // When we populate the display we do it from mutableRecordsArray rather than 
            // fetchedResultsController so we'll use recordNum to index in cellForRowAt rather than
            // indexPath
            
           // recordNum = 0
            
            tableView.reloadData()
     }
        
        
    }

    


  
    func getFRC() -> NSFetchedResultsController<NSFetchRequestResult>
    {
        let notesFetchRequest: NSFetchRequest<Note> = Note.fetchRequest() as! NSFetchRequest<Note>

        // Add Sort Descriptor
        let sortDescriptor = NSSortDescriptor(key: "noteModifiedDateTS", ascending: false)
        
        // Add predicate noteRecord.noteModifiedDateTS!
        
        if bSearchEntries  {
            notesFetchRequest.predicate = NSCompoundPredicate (andPredicateWithSubpredicates: predicateArray)
            let notetitleSortDescriptor = NSSortDescriptor(key: "notesList.noteName", ascending: false)
            notesFetchRequest.sortDescriptors = [notetitleSortDescriptor, sortDescriptor]
        } else {
            datedNotesPredicate = NSPredicate(format: "notesList == %@",  noteBaseRecord as CVarArg)
            notesFetchRequest.predicate = datedNotesPredicate
            notesFetchRequest.sortDescriptors = [sortDescriptor]
        }
        
        // Set section level based on search or no-search
        var sectionType = String("noteModifiedDateDay")
        if bSearchEntries  {
            sectionType = "notesList.noteName"
        }
        
        // Initialize Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: notesFetchRequest, managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: sectionType, cacheName: nil)

        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController as! NSFetchedResultsController<NSFetchRequestResult>
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
                let currentCell = tableView.cellForRow(at: indexPath) as! TSNoteEntriesTableCell
                configureCell(currentCell, atIndexPath: indexPath, currentRecord: noteRecord)
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
            
            /*
            if bNewNote {
                tableView.reloadData()
            }
            */
            break;
        }
        
        tableView.reloadData()

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

/*
    // Configure table cell
    func configureSearchMatchCell(_ cell: TSNoteEntriesTableCell, atIndexPath indexPath: IndexPath, noteRecord: Note!) {
        
        currentCell = cell
        
        // clear string?
//        myMutableString?.mutableString.setString("")
        
        // Update Cell
        let cellText = noteRecord?.value(forKey: "noteText") as? String
        myMutableString.mutableString.setString(cellText!)
        
        let textLength = cellText?.characters.count
        var firstFindRange = NSRange( location: 0, length: 1) // Default to start of text
        var foundRange = NSRange( location: 0, length: textLength!)
        var bfirstFind = Bool(true)
        
        for word in wordCollection {
            foundRange = highlightWord1(wordToFind: word, lengthEntireString: textLength!)
            
            if bfirstFind {
                firstFindRange = foundRange
                bfirstFind = false
            }
        }
        
        
        cell.noteTextView.attributedText = myMutableString
        cell.noteTextView.scrollRangeToVisible(firstFindRange)
    }
*/
    

    // Configure table cell
    func configureCell(_ cell: TSNoteEntriesTableCell, atIndexPath indexPath: IndexPath, currentRecord: Note!) {
        
        currentCell = cell
        
        // Fetch Record
        let record = fetchedResultsController.object(at: indexPath) 
        
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
            NSLog("number of Sections: \(sections.count)")
            return sections.count
        }
        
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            
         //   NSLog("number Of Rows In Section \(section): \(sectionInfo.numberOfObjects)")
            
            // set table title
//            setStatusText(queryString: searchString!, count: tableEntriescount, allReq: bListAll!)
//            navigationItem.title = statusText

            
            return sectionInfo.numberOfObjects
        }
        
        return 0
    }
    
        

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        noteRecord = fetchedResultsController.object(at: indexPath) //as Note
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TSNoteEntriesTableCell", for: indexPath) as! TSNoteEntriesTableCell
        
        let sectionName = noteRecord.noteModifiedDateTime
        var firstFindRange = NSRange( location: 0, length: 1)
        
       // NSLog( "\n\nIn cellForRowAt noteRecord: \(String(describing: self.noteRecord.noteText))\n\n")

        recordNum = objectRecordPtr [indexPath.section] [indexPath.row]
        myMutableString = mutableRecordsArray [recordNum]

        if bSearchEntries {
            
            // reformat the sectionName info
            let sectionNameReformatted = displayDateOnlyFormatter.string(from: noteRecord.noteModifiedDateTS!)

            cell.noteEntryDateLabel.text = sectionNameReformatted + ":    " + sectionName!

            firstFindRange = firstMatchLocArray [recordNum]
        }

        else {
            cell.noteEntryDateLabel.text = sectionName
            firstFindRange = NSRange( location: 0, length: 1)        }

        cell.noteTextView.attributedText = myMutableString
        cell.noteTextView.scrollRangeToVisible(firstFindRange)
        
        /*
        cell.layer.masksToBounds = true
        cell.layer.borderColor = UIColor( red: 0/255, green: 150/255, blue:115/255, alpha: 1.0 ).cgColor
        cell.layer.borderWidth = 0.5
      */
        
        return cell
    }
    
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if bSearchEntries {
            // Set name of section header
            sectionName = sectionNameArray[section]
        }
        else {
            
            if let sections = fetchedResultsController.sections {
                let sectionInfo = sections[section]

                sectionName = sectionInfo.name

                    // reformat the sectionName info
                let doDate = sortableDateOnlyFormatter.date(from: sectionName)
                let sectionNameReformatted = displayDateOnlyFormatter.string(from: doDate!)
                sectionName = sectionNameReformatted
            }
        }
        
        return sectionName
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
                let record = self.fetchedResultsController.object(at: indexPath) as NSManagedObject
                
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
            let record = fetchedResultsController.object(at: indexPath) as NSManagedObject
            
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


    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchString = searchBar.text!
        bSearchEntries = true
        
        predicateArray.removeAll()
        mutableRecordsArray.removeAll()
        
        searchBar.endEditing(true)
        
        viewWillAppear(false)
    }

    
    
/*
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
*/
    

    
    // MARK: - Navigation
    
    @IBAction func cancelAction(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    //let segueIndentifier = "presentNoteEntryEdit"
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let segID = segue.identifier
        
        let navVC = segue.destination as! UINavigationController
        let destinationVC = navVC.viewControllers.first as! noteEntryViewController

        bNewNote = segID == "newNoteEntry"
        
        if bNewNote { // set up new note
            destinationVC.noteText.mutableString.setString("")
            
        } else { // set up note modification
            
                if let indexPath = tableView.indexPathForSelectedRow {
                
                    // Fetch note record
                    noteRecord = fetchedResultsController.object(at: indexPath) //as Note

                    recordNum = objectRecordPtr [indexPath.section] [indexPath.row]
                    destinationVC.noteText = mutableRecordsArray [recordNum]
                    destinationVC.noteModDateTime = noteRecord.noteModifiedDateTS!
                    }
            }
        
        destinationVC.bNewNote = bNewNote
        destinationVC.noteName = noteName
 
    }
    
    
    
    @IBAction func unwindFromNoteEntry(_ sender: UIStoryboardSegue) {
   
        if let sVC = sender.source as? noteEntryViewController {
        
/*            var nbRecord = NoteBase()
            nbRecord = noteRecord.notesList!
            print ("Note Base record = \(nbRecord))\n")
*/
            if bNewNote {
               
                // If in search mode, we need to get noteBaseReord

                
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
            
            
      //      noteBaseRecord.modifyDateTS = Date()
            noteBaseRecord.modifyDateTS = Date()
            
            noteRecord.noteText = sVC.noteText.string
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
    

    // As of 7/7/17, this is not used
/*
    // updates the table view with the search results as user is typing...
    func updateSearchResults(for searchController: UISearchController) {
        
        // process the search string, remove leading and trailing spaces
        let searchString = searchController.searchBar.text!
        let trimmedSearchString = searchString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        // if search string is not blank
        if !trimmedSearchString.isEmpty {
            
            // form the search format
            let fetchPredicate = NSPredicate(format: "(name contains [cd] %@)", trimmedSearchString)
            
            // add the search filter
            notesFetchRequest.predicate = fetchPredicate
        }
        else {
            
            // reset to all records if search string is blank
            notesFetchRequest.predicate = nil
        }
        
        // refresh the table view
        self.tableView.reloadData()
    }

*/
    


    // MARK: - Helper functions

    // Form compound predicate from submitted search string
    func buildPredicate ( searchString: String ) {
        
        wordCollection = searchString.components(separatedBy: " ")
        
        if wordCollection.count == 0 {
            wordCollection.append(searchString)
        }
        
        // Save first term for positioning table display cells
        firstSearchTerm = wordCollection[0]
        
        for word in wordCollection {
            let trimWord = word.trim()
            if trimWord.characters.count > 0 {
                predicateArray.append(NSPredicate(format: "noteText CONTAINS[cd] %@", trimWord))
            }
        }
    }
        

    // Fetch a NoteBase record
    func fetchNoteBaseRecord() {
        
        // Initialize fetch request
    //    let baseFetchRequest = NSFetchRequest<NoteBase>(entityName: "NoteBase")
        let baseFetchRequest = NoteBase.fetchRequest() as! NSFetchRequest<NoteBase>         //NSFetchRequest<NoteBase>(entityName: "NoteBase")
        
        // Add Sort Descriptors
        //let sortDescriptor = NSSortDescriptor(key: "modifyDateTS", ascending: false)
        //baseFetchRequest.sortDescriptors = [sortDescriptor]
        
        // Specify the record we want
        let nbFetchPredicate = NSPredicate (format:"(noteCreateDate == %@", noteRecord.notesList! as NoteBase)
        baseFetchRequest.predicate = nbFetchPredicate
        
        // Initialize Fetched Results Controller
       baseFetchedResultsController = NSFetchedResultsController(fetchRequest: baseFetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)


    }
    

/*
    // Count matches in note text -- no longer used
    func countMatches(stringToFind: String, stringToSearch: String) -> Int {

        var localStringToSearch = String(stringToSearch)
        var occurrenceStartIndex: String.Index
        var count = 0
        while let foundRange = localStringToSearch?.range(of: stringToFind, options: .caseInsensitive) {
            occurrenceStartIndex = foundRange.lowerBound
            localStringToSearch = localStringToSearch?.replacingCharacters(in: foundRange, with: "")
            
            matchLocations.append(foundRange.lowerBound)
            count += 1
        }
        return count
    }
*/
    
/*

    // Highlight search match words. Now useing the information we found when we dic the predicate-based record fetch
    func highlightWord1 ( workString: NSMutableAttributedString, matchEntries: [NSRange] ) -> NSRange {
     
        var firstFindRange = NSRange( location: 0, length: workString.length)
        
        let searchStrLen = wordToFind.characters.count
        
        var msRange = NSRange( location: 0, length: strLength)
        var firstFindRange = NSRange( location: 0, length: lengthEntireString)
        let endRange = NSRange(location: lengthEntireString, length: searchStrLen)
        
        var msRange = NSRange( location: 0, length: lengthEntireString)
        var bFirstFind = Bool(true)
        
        var bCanSearchAgain = Bool(true)
        
        repeat {
            
            msRange = myMutableString.mutableString.range(of: wordToFind!, options: NSString.CompareOptions.caseInsensitive, range: searchRange)
            if msRange.location < strLength{
                print("found location is: \(msRange.location)")
                searchRange.location += searchStrLength!
                strLength = strLength - searchStrLength!
                searchRange.length = strLength
            } else {
                bCanSearchAgain = false
            }
            
        } while bCanSearchAgain
        
        self.myMutableString.addAttribute( NSBackgroundColorAttributeName,value: UIColor.yellow, range: r)
        
        NSLog( "myMutableString after: \(self.myMutableString)")
        
        
        
        
        for matchEntry in matchEntries {
            
            r.location = matchEntry.location
            r.length = matchEntry.length
            
            workString.addAttribute( NSBackgroundColorAttributeName,value: UIColor.yellow, range: r)

            
        }
        
        
        
        
        return firstFindRange
   }

    

    // Highlight search match words
    func highlightWord ( wordToFind: String, lengthEntireString: Int)  {
        
        
        let searchStrLen = wordToFind.characters.count
        
        var msRange = NSRange( location: 0, length: strLength)
        var firstFindRange = NSRange( location: 0, length: lengthEntireString)
        let endRange = NSRange(location: lengthEntireString, length: searchStrLen)
    
        var msRange = NSRange( location: 0, length: lengthEntireString)
        var bFirstFind = Bool(true)

        var bCanSearchAgain = Bool(true)

        repeat {
            
            msRange = myMutableString.mutableString.range(of: wordToFind!, options: NSString.CompareOptions.caseInsensitive, range: searchRange)
            if msRange.location < strLength{
                print("found location is: \(msRange.location)")
                searchRange.location += searchStrLength!
                strLength = strLength - searchStrLength!
                searchRange.length = strLength
            } else {
                bCanSearchAgain = false
            }
            
        } while bCanSearchAgain
        
                       self.myMutableString.addAttribute( NSBackgroundColorAttributeName,value: UIColor.yellow, range: r)

                        NSLog( "myMutableString after: \(self.myMutableString)")
        
        
        
        }
 */
    
    
  /*
    // Count matches for search word(s) ===>  needs to change to include multiple search words
    func countAndHighlightMatches( stringToFind: String, entireString: NSMutableAttributedString, recordNum: Int) -> Int {

        //var stringToSearch = entireString.mutableString

      //  equ highlightAttribute = NSBackgroundColorAttrib,value: UIColor.yellow
        
        let entireStringLen = entireString.mutableString.length
        var searchedStrLength = entireString.mutableString.length
        var searchRange = NSRange(location: 0, length: searchedStrLength )       //NSRange()
        var msRange = NSRange( location: 0, length: searchedStrLength)
        
        let searchStrLen = stringToFind.characters.count
        
        var bFirstFind = Bool(true)
        
        var bCanSearchAgain = Bool(true)
        var matchCount = Int(0)
        
        repeat {
            
            msRange = entireString.mutableString.range(of: stringToFind, options: NSString.CompareOptions.caseInsensitive, range: searchRange)
            
            if msRange.location <= entireStringLen - searchStrLen {
                
                print("found location is: \(msRange.location)")
                
               entireString.addAttribute( NSBackgroundColorAttributeName,value: UIColor.yellow, range: msRange)
                
                // Maybe save first find location
                if bFirstFind {
                    bFirstFind = false
                    firstMatchLocArray.insert(msRange, at: recordNum)
                 }
               
                matchCount += 1
                searchRange.location = msRange.location + searchStrLen
                searchedStrLength = entireStringLen - searchRange.location
                searchRange.length = searchedStrLength

 //                NSLog( "myMutableString after: \(self.myMutableString)")
                
            } else {
                bCanSearchAgain = false
            }
            
        } while bCanSearchAgain
        
        return matchCount
    }
*/

func setStatusText(queryString: String, count: Int, allReq: Bool)  {
    
    var countType1 = String()
    var countType2 = String()
    
    if bSearchEntries {
        countType2 = " matches"
        countType1 = " match"
        statusText = searchString! + ": "
    } else {
        
        countType2 = " entries"
        countType1 = " entry"
        statusText = ""
        
    }
    
    
    if tableEntriescount == 0 {
        statusText = statusText + "no " + countType2
    } else if tableEntriescount == 1 {
        statusText = statusText + "1 " + countType1
    } else {
        statusText = statusText + String(tableEntriescount) + " " + countType2
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
    



}  // ==> End of noteEntriesTableViewController class definition


// Update for Swift 3 (Xcode 8):
extension String {
    func nsRange(from range: Range<String.Index>) -> NSRange {
        let from = range.lowerBound.samePosition(in: utf16)
        let to = range.upperBound.samePosition(in: utf16)
        return NSRange(location: utf16.distance(from: utf16.startIndex, to: from),
                       length: utf16.distance(from: from, to: to))
    }
    
    func trim() -> String
    {
        return self.trimmingCharacters( in: NSCharacterSet.whitespaces)
    }

    
}


struct tempRange {
    var location:  String.Index
    var length: Int
    
    init () {
        let simpleString = " "
        location = String.Index.init(simpleString.unicodeScalars.index(of: " ")!, within: simpleString)!     //init(0, within: " ")
        length = 0
    }
}


    // Actions

    /*
    @IBAction func noteEntrySelectedForEdit(sender: UITapGestureRecognizer) {
        noteSelectedForEdit()
    }
    */
    
    func noteSelectedForEdit(){
        print("User selected note")
    
    }

