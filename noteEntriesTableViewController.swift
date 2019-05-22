//
//  noteEntriesTableViewController.swift - This is the table giving the entries for a particular note
/*
 
 ==> 7/19/18 Changing modified date to date set in note entry. It may have been edited and the possibly
        new date is more reflective of the note history.  Might want to add the mod date at some point.
 
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



class noteEntriesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate, UICollectionViewDelegate {
    
    // MARK: - Outlets
    
    // searchbar from storyboard
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    @IBOutlet weak var NoteEntriesTitle: UINavigationItem!
    
    
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
    
    var numRecords = Int(0)
    var sectionNum = Int(0)
    var numHits = Int(0)
    
    var latestNoteDate = Date()
    
    // MARK: - variables to and from NoteBaseTableController
    var managedObjectContext: NSManagedObjectContext!
    var noteBaseRecord: NoteBase!
    var bSearchEntries = Bool(false)
    var searchString: String?
    
    var bEntryModified = Bool(false)


    
    // MARK: - local variables
    
    var noteName = String()
    var noteCreateDate = Date()
    var statusText = String()
    var bNewNote = true
    var noteRecord = Note(context:moc)   // firstEntity = FirstEntity(context:context)
    
    // Temporary add to get lastest elapsed date from noteEntries
    var latestModifiedDate = Date()


    var cellWidth = CGFloat(45)
    var offsetPoint = CGPoint()
    var yDisplacement = Int()
    
    var numSections = Int()
    
    var lineStyle = NSMutableParagraphStyle()
    
    var contentOffset = CGPoint ()
    
    let displayDateFormatter = DateFormatter()
    let sortableDateOnlyFormatter = DateFormatter()
    let displayDateOnlyFormatter = DateFormatter()
    let displayTimeOnlyFormatter = DateFormatter()
    
    // Temporary debug vars
    var sectionName = String()
//    var noteText = String()
//    var noteModDateTime = Date()
    var currentDateTime = Date()
    var modifyDateArray = [Date()]
    var modifyDateArray1 = [Date()]

    // MARK: - variables associated with search

    var cellText = String()
    var myMutableString = NSMutableAttributedString()
    let myAttribute = [ NSAttributedStringKey.font: UIFont(name: "Papyrus", size: 16.0)! ]
 
    var wordCollection = [(String())]
    var firstSearchTerm: String?
    var predicateArray = [NSPredicate]()
    var datedNotesPredicate = NSPredicate()
    var tableEntriescount = Int(0)
    var matchCount = Int(0)
    var recordNum = Int(0)
    var objectRecordPtr = [[Int]]()
    var objectRecordPtr1 = [[Int]]()
    var objectRecordPtrDim2 = [Int]()
  // var matchLocations: [String.Index] = []
    //var matchArray = [[tempRange]()]
    var firstMatchLocArray = [NSRange]()
    var mutableRecordsArray = [NSMutableAttributedString]()
    var xferVar = NSMutableAttributedString()
    var sectionNameArray = [String]()
    var currentBaseRecord: NoteBase!
    var firstFindRange = NSRange( location: 0, length: 1)


    // MARK: - Code section
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
       // MARK - 2/15/17 right off the bat we need to decide if we've been called to search or
        //   provide a normal display.  Perhaps we should separate the search function in its own
        //   controller and display
        
       
        displayDateFormatter.dateFormat = "h:mm a  EEEE, MMMM d, yyyy"
        sortableDateOnlyFormatter.dateFormat = "yyyy.MM.dd"
        displayDateOnlyFormatter.dateFormat = "MMMM, d yyyy, EEEE"     //"EEEE MMMM, d yyyy"  
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
 //       var contentOffset: CGPoint = self.tableView.contentOffset
        
        contentOffset = self.tableView.contentOffset
        contentOffset.y += (self.tableView.tableHeaderView?.frame)!.height
        self.tableView.contentOffset = contentOffset
        
        
        // This implements tap/double tap on the navigation bar to scroll the list to the top or bottom
        let singleTap = UITapGestureRecognizer(target: self, action:#selector(self.singleTapAction(_:)))
        singleTap.delegate = self
        singleTap.numberOfTapsRequired = 1
        self.navigationController?.navigationBar.addGestureRecognizer(singleTap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action:#selector(self.doubleTapAction(_:)))
        doubleTap.delegate = self
        doubleTap.numberOfTapsRequired = 2
        self.navigationController?.navigationBar.addGestureRecognizer(doubleTap)
        
        // This effects discrimination of single/double tap
        singleTap.require(toFail: doubleTap)
        
        if bSearchEntries {
            buildPredicate ( searchString: searchString! )
        }
        

        // Set up core data for notes
        fetchedResultsController = getFRC() as! NSFetchedResultsController<Note>

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableEntriescount = 0
        
        if bSearchEntries {
            searchBar.text = searchString
        } else {
            noteName = noteBaseRecord.noteName!
            navigationItem.title = noteName
            statusText = noteName
            //tableView.contentOffset = CGPoint(x:0, y:searchBar.frame.height);
        }
       
        
         fetchRecords ()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if bSearchEntries {
            // set table title
            setStatusText(queryString: searchString!, count: numHits)
        }
        
        navigationItem.title = statusText

       // This is done because the first view of the table doesn't include the
        // scrolltovisible actions
        tableView.reloadData()
        
    }
    
    func scrollTableCells() {
        /*
        for cell in tableView.visibleCells as! [UITableViewCell] {
            //do someting with the cell here.
            
        }
        */
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

   
    //MARK: - fetchRecords
    func fetchRecords () {
        

        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
        
       // numRecords = fetchedResultsController.fetchedObjects!.count
        numHits = fetchedResultsController.fetchedObjects!.count

        if numHits > 0 {

            recordNum = 0
            matchCount = 0
            currentBaseRecord = nil
            var bNewRecord = Bool (true)
            var currentSectionNumber = Int (0)
            var sectionNumber = Int()

            
            // Clear out arrays so they don't keep increasing
            objectRecordPtr1.removeAll()
            modifyDateArray1.removeAll()
            mutableRecordsArray.removeAll()
            objectRecordPtrDim2.removeAll()

            for object in fetchedResultsController.fetchedObjects! {
                
                // Save the modify date to later compute elapsed times between entries
                modifyDateArray1.append(object.noteModifiedDateTS!)

                
                // Temporary add #ed to get lastest elapsed date from noteEntries
                // default to existing latest date
                if recordNum == 0 {
                    latestModifiedDate = object.noteModifiedDateTS!
               }

                let pos = fetchedResultsController.indexPath(forObject: object)
                
                guard pos != nil else {
                    print("Null value from fetchedResultsController for \(object.noteText!)")
                    
                    let alertController = UIAlertController(title: "TS Notes", message:
                        "No path information for ?", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    self.present(alertController, animated: true, completion: nil)

                    return
                }
                 sectionNumber = pos![0]
                
                if sectionNumber > currentSectionNumber {
                    if sectionNumber > 0 {
                        objectRecordPtr1.insert(objectRecordPtrDim2, at: currentSectionNumber)
                        currentSectionNumber = sectionNumber
                    }
                    objectRecordPtrDim2.removeAll()
                }
                
                objectRecordPtrDim2.append(recordNum)

   //             objectRecordPtr[(pos?[0])!][(pos?[1])!] = recordNum


                bNewRecord = true

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
                    
                    for word in wordCollection {
                        
                        searchString = word
                        //searchString = wordCollection[0]
                        // Highlight (and count) matches
                        let results = Utils.countAndHighlightMatchesHelper( stringToFind: searchString!, entireString: xferVar)
     
                       matchCount += results.matchCount

                        if bNewRecord {
                            firstMatchLocArray.insert(results.firstFindRange, at: recordNum)
                            bNewRecord = false
                        } else if results.firstFindRange.location <  firstMatchLocArray[recordNum].location {
                            firstMatchLocArray[recordNum] = results.firstFindRange
                        }

                    }
                }
                
                xferVar.addAttributes(myAttribute, range:NSRange(location: 0,length: (xferVar.length)))
                mutableRecordsArray.insert(xferVar, at: recordNum)
                
                if recordNum == 0 {
                    
                    // Take an opportunity to populate noteBaseRecord pointer
                    noteBaseRecord = object.notesList
 
                }
                
                recordNum += 1

            }
            
            // Take care of possible last section
            if sectionNumber > -1 {
                objectRecordPtr1.insert(objectRecordPtrDim2, at: sectionNumber)
             }
            
            // And I think we have 1 to many in recordNum, and need to clear  objectRecordPtrDim2

            recordNum -= 1



            // When we populate the display we do it from mutableRecordsArray rather than 
            // fetchedResultsController so we'll use recordNum to index in cellForRowAt rather than
            // indexPath
            
           // recordNum = 0
            
            /*
            tableView.reloadData()
        //    self.tableView.contentOffset = contentOffset
            if numHits > 0 {
                let indexPath = NSIndexPath(row: 0, section: 0)
                self.tableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: false)
            }
            */
        }
        
        
    }

  
    func getFRC() -> NSFetchedResultsController<NSFetchRequestResult>
    {
        let notesFetchRequest: NSFetchRequest<Note> = Note.fetchRequest() as! NSFetchRequest<Note>
        
        currentDateTime = Date()

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
 
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self

        // Initialize Fetched Results Controller
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: notesFetchRequest, managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: sectionType, cacheName: nil)

        return self.fetchedResultsController as! NSFetchedResultsController<NSFetchRequestResult>
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
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()

    }
        
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
 
        if let sections = fetchedResultsController.sections {
            numSections = sections.count
            NSLog("noteEntries: number of Sections: \(numSections)")
            return numSections
        }
        
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            
         //ri   NSLog("number Of Rows In Section \(section): \(sectionInfo.numberOfObjects)")
            
            // set table title
           // setStatusText(queryString: searchString!, count: tableEntriescount, allReq: bListAll!)
            navigationItem.title = statusText
  
            if cellWidth == 0 {
                cellWidth = (tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.bounds.size.width)!
            }

            return sectionInfo.numberOfObjects
        }
        
        return 0
    }
    
        

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        noteRecord = fetchedResultsController.object(at: indexPath) //as Note
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TSNoteEntriesTableCell", for: indexPath) as!          TSNoteEntriesTableCell
        
        let sectionName = noteRecord.noteModifiedDateTime
        
       // NSLog( "\n\nIn cellForRowAt noteRecord: \(String(describing: self.noteRecord.noteText))\n\n")

   //     recordNum = objectRecordPtr [indexPath.section] [indexPath.row]
        recordNum = objectRecordPtr1 [indexPath.section] [indexPath.row]
        myMutableString = mutableRecordsArray [recordNum]
        
        if recordNum < numHits - 1 {
            cell.elapsedTimeLabel.text = Utils.dateDifference(laterDate: modifyDateArray1 [recordNum], earlierDate: modifyDateArray1 [recordNum+1])
        }
 
       cell.noteTextView.attributedText = myMutableString
 
        if bSearchEntries {
            
            // reformat the sectionName info
            let sectionNameReformatted = displayDateOnlyFormatter.string(from: noteRecord.noteModifiedDateTS!)

            cell.noteEntryDateLabel.text = sectionNameReformatted + ":    " + sectionName!
            firstFindRange = firstMatchLocArray [recordNum]
        }

        else {
            cell.noteEntryDateLabel.text = sectionName
            firstFindRange = NSRange( location: 0, length: 1)
            firstFindRange = NSMakeRange( 0, 1)

        }

        cell.noteTextView.attributedText = myMutableString
        
        
        if firstFindRange.location > 0 {
            firstFindRange.location -= 0
        }
  
        cell.noteTextView.scrollRangeToVisible(firstFindRange)

        cell.layer.masksToBounds = true
        cell.layer.borderColor = UIColor( red: 0/255, green: 150/255, blue:115/255, alpha: 1.0 ).cgColor
        cell.layer.borderWidth = 0.5
      
        
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
            //    let sectionNameReformatted = displayDateOnlyFormatter.string(from: doDate!)
           //     sectionName = sectionNameReformatted
                sectionName = displayDateOnlyFormatter.string(from: doDate!)
           }
        }
        
        return sectionName
  }
    
    // Set section header font/size
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header = view as! UITableViewHeaderFooterView
        //make the background color light blue
        header.contentView.backgroundColor = UIColor(red: 0.84, green: 0.93, blue: 0.93, alpha: 1.0)
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
                /*
                // Delete the record
                do {
                    try self.managedObjectContext.save()
                    //5
                } catch let error as NSError  {
                    print("Could not save \(error), \(error.userInfo)")
                }
                */

                
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
                print("Delete button tapped #2")
                
                // I think I need to do this to update the table display
                self.fetchRecords ()
                self.tableView.reloadData()


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
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "unwindFromNoteEntries", sender: self)
        
    }
    
    //let segueIndentifier = "presentNoteEntryEdit"
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // cancel seques come througth here
        guard let segID = segue.identifier else {
            
            // #ed  Temporary logic to populate new notebase field latestModifiedDate
            if noteBaseRecord.value(forKey: "latestNoteDate") == nil {
                noteBaseRecord.setValue(latestModifiedDate, forKey:"latestNoteDate")
            
            // Create/update note entity
            updateDataObject ()

            }

            return
        }
        
        let navVC = segue.destination as! UINavigationController
        let destinationVC = navVC.viewControllers.first as! noteEntryViewController

        bNewNote = segID == "newNoteEntry"
        
        if bNewNote { // set up new note
            destinationVC.noteText.mutableString.setString("")
            
        } else { // set up note modification
            
                if let indexPath = tableView.indexPathForSelectedRow {
                
                    // Fetch note record
                    noteRecord = fetchedResultsController.object(at: indexPath) //as Note

                //    recordNum = objectRecordPtr [indexPath.section] [indexPath.row]
                    recordNum = objectRecordPtr1 [indexPath.section] [indexPath.row]
                    destinationVC.noteText = mutableRecordsArray [recordNum]
                    destinationVC.noteModDateTime = noteRecord.noteModifiedDateTS!
                    }
            }
        
        destinationVC.bNewNote = bNewNote
        destinationVC.noteName = noteName
 
    }
    
    
    @IBAction func unwindFromNoteEntryCancel(_ sender: UIStoryboardSegue) {
    }

    @IBAction func unwindFromNoteEntrySave(_ sender: UIStoryboardSegue) {
   
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
            
            
      //      noteBaseRecord.modifyDateTS = Date()
            noteBaseRecord.modifyDateTS = Date()
            
            noteRecord.noteText = sVC.noteText.string
        
            // 10.14.18 Temporary copy until I figure out the occasional crash
            let pasteBoard = UIPasteboard.general
            pasteBoard.string = sVC.noteText.string
        /*
            if let strData = Data(base64Encoded: sVC.noteText.string) {
                pasteBoard.setData(sVC.noteText.string, forPasteboardType: <#string#> )
        }
        */

        
            noteRecord.noteModifiedDateDay = sortableDateOnlyFormatter.string(from: sVC.noteModDateTime! as Date)
            noteRecord.noteModifiedDateTime = displayTimeOnlyFormatter.string(from: sVC.noteModDateTime! as Date)
            noteRecord.noteModifiedDateTS  = sVC.noteModDateTime!
            
            // New (7.20.18) field in notebase record, latestNoteDate
            noteBaseRecord.setValue(noteRecord.noteModifiedDateTS, forKey:"latestNoteDate")

        // Create/update note entity
        updateDataObject ()
        
        }
    }
    
    // Update data object (note + notebase if needed)
    func updateDataObject () {
        
        do {
            try managedObjectContext.save()
            //5
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
    }

 


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
            if trimWord.count > 0 {
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
    

    // This insulates button taps from header taps
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isKind(of: UIControl.self) {
            return false
        }
        return true
    }

    
    
    // Handle navigation bar single tap - scroll to the t@objc op
    @objc func singleTapAction (_ theObject: UITapGestureRecognizer) {
        
        guard numHits > 0 else { return }
        
        if theObject.state == .ended {
            let indexPath = NSIndexPath(row: 0, section: 0)
            self.tableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: false)
        }

    }
    
    // Handle navigation bar double tap - scroll to th@objc e bottom
    @objc func doubleTapAction (_ theObject: AnyObject) {
        
        if theObject.state == .ended {
            
            /* replace this with code in notebase
            let numRows = tableView( tableView, numberOfRowsInSection: 0) - 1
            let indexPath = NSIndexPath(row: numRows, section: 0)
            self.tableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
             */
        
            let sections = fetchedResultsController.sections
            let numSections = (sections?.count)! - 1
            let sectionInfo = sections![numSections]
            let numRows = sectionInfo.numberOfObjects - 1
            // let numRows = tableView( tableView, numberOfRowsInSection: numSections[ - 1
            let indexPath = NSIndexPath(row: numRows, section: numSections)
            self.tableView.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: false)

        }
        
        // let sbHeight = searchBar.frame.height
       // tableView.contentOffset = CGPoint(x:0, y:searchBar.frame.height);
        
    }
    
    /// Issue alert
    ///
    /// - Parameters:
    ///   - title: <#title description#>
    ///   - message: <#message description#>
    func issueAlert (title: String, message: String){
        let fullTitle = "TS Notes: " + title
        let alertController = UIAlertController(title: fullTitle, message:
            message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
        
    



}  // ==> End of noteEntriesTableViewController class definition


// Update for Swift 3 (Xcode 8):
extension String {
    /*
    func nsRange(from range: Range<String.Index>) -> NSRange {
        let from = range.lowerBound.samePosition(in: utf16)
        let to = range.upperBound.samePosition(in: utf16)
        var myLength = range.upperBound - range.lowerBound + 1
        NSRange(location:range.distance(from: from, to: to),length:range.count)
        return NSRange(location: utf16.distance(from: utf16.startIndex, to: from),
                       length: utf16.distance(from: from, to: to))
    }
    */
    
    func range(nsRange: NSRange) -> NSRange? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(utf16.startIndex, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let from = from16.samePosition(in: self),
            let to = to16.samePosition(in: self)
            else { return nil }
        return NSMakeRange(from.encodedOffset, to.encodedOffset)
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

