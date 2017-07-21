 //
//  noteEntriesTableViewController.swift - This is the table giving the entries for a particular note
/*
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

class noteEntriesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
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
    let calendar = Calendar.current
    
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
    var wordCollection = [(String())]
    var firstSearchTerm: String?
    var predicateArray = [NSPredicate]()
    var datedNotesPredicate = NSPredicate()
    var tableEntriescount = Int(0)
    var matchCount = Int(0)
    var matchLocations: [String.Index] = []
    //var matchArray = [[tempRange]()]
    var matchArray = [[NSRange]()]
    var mutableRecordsArray = [NSMutableAttributedString]()
    var xferVar = NSMutableAttributedString()
    var sectionNameArray = [String]()
    var currentBaseRecord: NoteBase!
    var expandedRecordCount = Int (0)
    var currentNoteModifiedDateDay = String("")
    var sectionExtraRowCounts = [Int]()
    var sectionERCIndex = Int(0)

    // MARK: - Code section
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
       // MARK - 2/15/17 right off the bat we need to decide if we've been called to search or
        //   provide a normal display.  Perhaps we should separate the search function in its own
        //   controller and display
        

        if bSearchEntries {
            buildPredicate ( searchString: searchString! )
        }
/*
        else {
            noteCreateDate = noteBaseRecord.createDateTS! as Date
            fetchPredicate = NSPredicate (format:"(noteCreateDate == %@", noteRecord.noteModifiedDateTS! as NSDate)
         }
 */
        
        displayDateFormatter.dateFormat = "h:mm a  EEEE, MMMM d, yyyy"
        sortableDateOnlyFormatter.dateFormat = "yyyy.MM.dd"
        displayDateOnlyFormatter.dateFormat = "EEEE MMMM,d yyyy"  // "EEEE, d MMMM yyyy"
        displayTimeOnlyFormatter.dateFormat = "h:mm a"
        
       
        fetchedResultsController = getFRC() as! NSFetchedResultsController<Note>
        
        // Mark: to implement dynamic row height
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableEntriescount = 0
        
        if !bSearchEntries {
            noteName = noteBaseRecord.noteName!
            navigationItem.title = noteName
        }
       
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
        
        // If we're doing a search, let's count and hightlight the hits.  We'll save them in 
        // mutableRecordsArray
        
       
            if let numHits = fetchedResultsController.fetchedObjects?.count {
                
                expandedRecordCount = 0         // count data records plus extra records for subsection headers
                currentNoteModifiedDateDay = "" // this tracks subsection changes - i.e. a new date
                matchCount = 0
                sectionERCIndex = -1  // Section counter
                sectionExtraRowCounts.append(0)
                currentBaseRecord = nil
                
                for object in fetchedResultsController.fetchedObjects! {
                    
                 //   let sectionNum = object.

                    // This seems like a hack but to actually get a copy (not just a reference) of
                    // myMutableString, you have to instantiate a new object so we do that with xferVar
                    
                    xferVar = NSMutableAttributedString(string: object.noteText! )
                    
                    NSLog("\n\nIn  fetchRecords, text of record# \(expandedRecordCount + 1) is: \(String(describing: object.noteText!))")
                    
                    // If we're searching, we want to have a subsection heading for dates.  So the table
                    // display will go:
                    //      Note name
                    //          Note date
                    //              note entries
                    //  We need to add extra rows to the table for the subsection (date) headings so we're going
                    //  to count them here.  Every time the base record changes we have a new section (note title).
                    //  When the date changes we have a new subsection and we have to add a row to the table to
                    //  display the date heading. We're keeping track of these in sectionExtraRowCounts indexed by
                    //  sectionERCIndex.
                    
                    if bSearchEntries {
                        
                        // If date of note(s) changes, add a record to display subsection header (note date)
                        // =======> USE MODIFIEDDATADAY!!!!  Create a count/ by section of added records (for dates)
                        
                        if currentBaseRecord != object.notesList {
                            currentBaseRecord = object.notesList
                            sectionERCIndex += 1
                            sectionExtraRowCounts.append(1)
                            
                        }
                        if currentNoteModifiedDateDay != object.noteModifiedDateDay {
                            currentNoteModifiedDateDay = object.noteModifiedDateDay!
                            xferVar.mutableString.setString( displayDateOnlyFormatter.string(from: object.noteModifiedDateTS!))
                            sectionExtraRowCounts [sectionERCIndex] += 1
                        }
                        else {
                            // Highlight (and count) matches
                           matchCount += countAndHighlightMatches( stringToFind: searchString!,
                                                                    entireString: xferVar)
                        }

                        
                    }
                    
                    mutableRecordsArray.insert(xferVar, at: expandedRecordCount)
                    
                    if expandedRecordCount == 0 {
                        
                        // Take an opportunity to populate noteBaseRecord pointer
                        noteBaseRecord = object.notesList
                    }
                    
                    expandedRecordCount += 1

                }
         }
       
        
       // bNewFetch = true
        
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

            NSLog("number Of Rows In Section: \(sectionInfo.numberOfObjects)")
            
            var totalSectionRows = sectionInfo.numberOfObjects
            if bSearchEntries {
        
                totalSectionRows += sectionExtraRowCounts [section]
            }
            tableEntriescount += totalSectionRows

            
            // set table title
//            setStatusText(queryString: searchString!, count: tableEntriescount, allReq: bListAll!)
//            navigationItem.title = statusText

            
            return totalSectionRows
        }
        
        return 0
    }
    
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        
        /*  We;re going to use this for searches to indent the row infor (and maybe the color) of a row. There are 3
            possibilities:
                1) Note title - main heading
                2) note date -
 
 
        */
        
        return 0
    }
    

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        noteRecord = fetchedResultsController.object(at: indexPath) //as Note
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TSNoteEntriesTableCell", for: indexPath) as! TSNoteEntriesTableCell
        
        
        
        // Configure Table View Cell - one of two types. If we're searching and it's the first entry for
        //  a particular note, we'll put the note day in a label (ID = TSNoteEntriesDateLabel) otherwise we'll put the
        //  cell info in the cell with ID TSNoteEntriesTableCell.
        
        if bSearchEntries && currentBaseRecord != noteRecord.notesList {
               currentBaseRecord = noteRecord.notesList
                
             let altCell = tableView.dequeueReusableCell(withIdentifier: "TSNoteEntriesDateLabelCell", for: indexPath) as! TSNoteEntriesDateLabelCell
            
                let sectionNameReformatted = displayDateOnlyFormatter.string(from: noteRecord.noteModifiedDateTS!)
                altCell.noteDateLabel.text = sectionNameReformatted

            return altCell
        }
        
        let sectionName = noteRecord.noteModifiedDateTime
    
//            NSLog( "\n\nIn cellForRowAt noteRecord: \(String(describing: self.noteRecord.noteText))\n\n")

        if bSearchEntries {
            let rowIndex = indexPath.row
            let sectionNum = indexPath.section
            
            // reformat the sectionName info
          //  let doDate = sortableDateOnlyFormatter.date(from: sectionName)
            let sectionNameReformatted = displayDateOnlyFormatter.string(from: noteRecord.noteModifiedDateTS!)

            cell.noteEntryDateLabel.text = sectionNameReformatted + ": " + sectionName!
            cell.noteTextView.attributedText = mutableRecordsArray [rowIndex]
        
        }
        else {
            cell.noteTextView.text = noteRecord.noteText
            cell.noteEntryDateLabel.text = sectionName
        }

           // cell.noteTextView.scrollRangeToVisible(firstFindRange)
        
        return cell
    }
    
    
    
/*
    func computeItemAndSubsectionIndexForIndexPath(_ indexPath: NSIndexPath) -> NSIndexPath {
        var sectionItems: NSMutableArray = fetchedResultsController.sections[UInt(indexPath.section)]
        var itemIndex: Int = indexPath.row
        var subsectionIndex: UInt = 0
        for var i: UInt = 0 ; i < sectionItems.count ; ++i {
            // First row for each section item is header
            --itemIndex
            // Check if the item index is within this subsection's items
            var subsectionItems: [AnyObject] = sectionItems[i]
            if itemIndex < Int(subsectionItems.count) {
                subsectionIndex = i
                break
            } else {
                itemIndex -= subsectionItems.count
                
            }
        }
        return NSIndexPath(row: itemIndex, section: subsectionIndex)
    }
*/
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if bSearchEntries {
            // Set name of section header
            sectionName = noteBaseRecord.noteName!
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
            destinationVC.noteText = ""
            
        } else { // set up note modification
            
                if let indexPath = tableView.indexPathForSelectedRow {
                
                    // Fetch note record
                    noteRecord = fetchedResultsController.object(at: indexPath)
                    destinationVC.noteText = noteRecord.noteText
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
    // Count matches in note text -- not longer used
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
    
    
    
    // Count matches for search word(s) ===>  needs to change to include multiple search words
    func countAndHighlightMatches( stringToFind: String, entireString: NSMutableAttributedString) -> Int {

        //var stringToSearch = entireString.mutableString

      //  equ highlightAttribute = NSBackgroundColorAttrib,value: UIColor.yellow
        
        let entireStringLen = entireString.mutableString.length
        var searchedStrLength = entireString.mutableString.length
        var searchRange = NSRange(location: 0, length: searchedStrLength )       //NSRange()
        var msRange = NSRange( location: 0, length: searchedStrLength)
        
        let searchStrLen = stringToFind.characters.count
        
        var firstFindRange = NSRange( location: 0, length: searchedStrLength)
        
        var bFirstFind = Bool(true)
        
        var bCanSearchAgain = Bool(true)
        var matchCount = Int(0)
        
        repeat {
            
            msRange = entireString.mutableString.range(of: stringToFind, options: NSString.CompareOptions.caseInsensitive, range: searchRange)
            
            if msRange.location <= entireStringLen - searchStrLen {
                
                print("found location is: \(msRange.location)")
                
               entireString.addAttribute( NSBackgroundColorAttributeName,value: UIColor.yellow, range: msRange)
                
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

