//
//  noteEntriesTableViewController.swift - This is the table giving the entries for a particular note
//  TSNotes
//
//  Created by Jeanne's MacBook on 11/12/15.
//  Copyright © 2015 LCI. All rights reserved.
//

import UIKit
import CoreData


class noteEntriesTableViewController: UITableViewController {
    
    // Properties
    
    
 //   var noteEntries = [TSNote]()

    var noteEntriesSeparated = [[TSNote]]()

    var noteCreateDate = NSDate()
    
    let calendar = NSCalendar.currentCalendar()
//    var dateOnlyComponents1 = calendar.components([.Day, .Month, .Year],  fromDate: noteCreateDate)
    
    var noteName = String()
    var sectionModDate = String()
    
    var noteEntries = [TSNote]()
    
    let longString1 = "When the user taps in a text field, that text field becomes the first responder and automatically asks the system to display the associated keyboard. Because the appearance of the keyboard has the potential to obscure portions of your user interface, it is up to you to make sure that does not happen by repositioning any views that might be obscured. Some system views, like table views, help you by scrolling the first responder into view automatically. If the first responder is at the bottom of the scrolling region, however, you may still need to resize or reposition the scroll view itself to ensure the first responder is visible."
    
   let longString2 = "It is your application’s responsibility to dismiss the keyboard at the time of your choosing. You might dismiss the keyboard in response to a specific user action, such as the user tapping a particular button in your user interface. You might also configure your text field delegate to dismiss the keyboard when the user presses the “return” key on the keyboard itself. To dismiss the keyboard, send the resignFirstResponder message to the text field that is currently the first responder. Doing so causes the text field object to end the current editing session (with the delegate object’s consent) and hide the keyboard."
    
    let longString3 = "The appearance of the keyboard itself can be customized using the properties provided by the UITextInputTraits protocol. Text field objects implement this protocol and support the properties it defines. You can use these properties to specify the type of keyboard (ASCII, Numbers, URL, Email, and others) to display. You can also configure the basic text entry behavior of the keyboard, such as whether it supports automatic capitalization and correction of the text."
    
   // var longString = longString1
    
    
    let displayDateFormatter = NSDateFormatter()
    let displayDateOnlyFormatter = NSDateFormatter()
    let displayTimeOnlyFormatter = NSDateFormatter()
    
    var bNewNote = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = noteName

        /*
        let dateString = "01-02-2010"
        let dateFormatter = NSDateFormatter()
        // this is imporant - we set our input date format to match our input string
        dateFormatter.dateFormat = "dd-MM-yyyy"
        // voila!
        var dateFromString = dateFormatter.dateFromString(dateString)
        */
    
  //      tableView.rowHeight = UITableViewAutomaticDimension
   //     tableView.estimatedRowHeight = 140.0
        
        // Set up sample array
    //    loadSampleNoteEntries()
    //    dayTimePeriodFormatter.dateFormat = "MMM d,yyyy h:m a"
   //     displayDateFormatter.dateFormat = "EEEE MMM d,yyyy         h:m a"
       // displayDateFormatter.dateFormat = "MMM d,yyyy h:m a"
        
        displayDateFormatter.dateFormat = "EEEE, MMMM d, yyyy h:mm a"
        displayDateOnlyFormatter.dateFormat = "EEEE, MMMM d, yyyy"
        displayTimeOnlyFormatter.dateFormat = "h:mm a"
        
        
        // put in an attempt to get note instance info
        //  from http://code.tutsplus.com/tutorials/core-data-and-swift-relationships-and-more-fetching--cms-25070
        

  
    }
    
    
    func configureTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120.0
    }
    
    override func viewWillAppear(animated: Bool) {
        let theNoteCreateDate = noteCreateDate
        NSLog("Note create date chosen: \(dayTimePeriodFormatter.stringFromDate(theNoteCreateDate))")
        NSLog("Note name chosen: \(noteName)")
        
        buildNoteEntriesArray()

    }

    
    /*
    func loadSampleNoteEntries() {
        let TSNote1 = TSNote(  "Nov 5 - This is a test note 1", modifyDate: "11-5-2015 8:05 AM",
            createDate: "11-5-2015 10:22 AM")
        let TSNote2 = TSNote(  "Nov 5 - This is a test note 2", modifyDate: "11-5-2015 11:05 AM",
            createDate: "11-5-2015 10:22 AM")
        let TSNote3 = TSNote(  "Nov 5 - This is a test note 3", modifyDate: "11-5-2015 3:50 PM",
        createDate: "11-5-2015 10:22 AM")
        let TSNote4 = TSNote(  "Nov 25 - This is a test note 4", modifyDate: "11-25-2015 9:17 AM",
        createDate: "11-25-2015 10:22 AM")
        let TSNote5 = TSNote(  "Nov 25 - This is a test note 5", modifyDate: "12-4-2015 8:15 AM",
        createDate: "11-25-2015 10:22 AM")
        let TSNote6 = TSNote(  "Nov 25 - This is a test note 6", modifyDate: "12-4-2015 2:22 PM",
        createDate: "12-1-2015 10:22 AM")
        let TSNote7 = TSNote( "Dec 1 -  \(longString1)", modifyDate: "12-10-2015 11:23 AM",
        createDate: "12-1-2015 10:22 AM")
        let TSNote8 = TSNote( "Dec 1 -  \(longString2)", modifyDate: "12-12-2015 1:07 PM",
        createDate: "12-1-2015 10:22 AM")
        
        
        noteEntries  += [TSNote1, TSNote2, TSNote3, TSNote4, TSNote5, TSNote6, TSNote7, TSNote8]
        //noteEntries  += [ TSNote5, TSNote6, TSNote7, TSNote8]
        

        
    }

    */
    
    func buildNoteEntriesArray() {
        var modDate: NSDate
        
 //       var createDate: NSDate
        var compareDate = NSDate.distantPast()
        var sectionIndex = -1
        var entryIndex = 0
        
        
        // Go through note entries, separate by modify date
        
        for noteEntry in noteEntries {
            
            // If note entry create date not same as note create date, don't include
            var order = calendar.compareDate(noteCreateDate, toDate: noteEntry.createDateTime, toUnitGranularity: .Day)
            
            if order != .OrderedSame  {
                    continue
            }
            
            // Create date is the same, use this entry
            modDate = noteEntry.modifyDateTime
            
            order = calendar.compareDate(compareDate, toDate: modDate,
                toUnitGranularity: .Day)
            
            // same modify date, add to existing row
            if order == .OrderedSame  {
                
                //     print ( "same date add for section index \(sectionIndex), entry index \(entryIndex)             note text is: \(noteEntry.noteText)")
                
                
                noteEntriesSeparated[sectionIndex].insert(noteEntry, atIndex: entryIndex)
                
                //    NSLog("New modify date for same date", noteEntriesSeparated[sectionIndex][ entryIndex].modifyDateTime)
                
                entryIndex += 1
                
            }
                // new modify date, start a new row
            else {
                sectionIndex += 1
                compareDate = modDate
                entryIndex = 1
                
                //    print ( "new date add for section index \(sectionIndex), entry index \(entryIndex)             note text is: \(noteEntry.noteText)")
                
                noteEntriesSeparated.insert([noteEntry], atIndex: sectionIndex)
                //               NSLog("New array entry for nwq date", noteEntriesSeparated[sectionIndex])
                //       NSLog("New modify date for new date", noteEntriesSeparated[sectionIndex][ 0].modifyDateTime)
                
            }
            
        }
                
    }

    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        // We need to determine number of sections from number of unique dates in note entries
        return noteEntriesSeparated.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        // We need to determine the number of entries per date for the note
        return noteEntriesSeparated[section].count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TSNoteEntriesTableCell", forIndexPath: indexPath) as! TSNoteEntriesTableCell

        //NSLog("working with section: \(indexPath.section)")

        // Configure the cell...
        let noteEntry = noteEntriesSeparated [indexPath.section][indexPath.row]

        // get modifcation date and note text
       // cell.noteDateLabel.text = displayDateFormatter.stringFromDate(noteEntry.modifyDateTime)
        
       cell.tableCellNoteDateLabel.text = displayTimeOnlyFormatter.stringFromDate(noteEntry.modifyDateTime)

        cell.noteTextView.text = noteEntry.noteText
        
       // UITableView.titleForHeaderInSection (5)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        // Set name of note
     //   return noteName
        let noteModDate = noteEntriesSeparated [section][0].modifyDateTime
        let modDateStr = displayDateOnlyFormatter.stringFromDate(noteModDate)
        return modDateStr
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSLog("Selected section is: \(indexPath.section) and row is: \(indexPath.row)")
        let noteEntry = noteEntriesSeparated [indexPath.section][indexPath.row]
        NSLog("Cell text is: \(noteEntry.noteText)")

    }
    
/*
    override func viewWillAppear(animated: Bool) {
        noteTimeLabel.text = noteTime
    }
  */  

    
    // Navigation
    @IBAction func cancelButton(sender: AnyObject) {
        
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }else{
            
            print("optional value")
            
            
        }
    }
    
    //let segueIndentifier = "presentNoteEntryEdit"
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
       let segID = segue.identifier
        
        guard   segID == "newNoteEntry" || segID == "modNoteEntry"  else {
            // Value requirements not met, do something
            return
        }
        
        let navVC = segue.destinationViewController as! UINavigationController
        let destinationVC = navVC.viewControllers.first as! noteEntryViewController

        destinationVC.noteName = noteName
        destinationVC.bNewNote = true

        
        
        if segue.identifier == "modNoteEntry" {
            
            let row = self.tableView.indexPathForSelectedRow!.row
            let section = self.tableView.indexPathForSelectedRow!.section
            
            let noteEntry = noteEntriesSeparated [section][row]
            // NSLog("noteEntriesTableViewController - Cell text is: \(noteEntry.noteText)")
            // print("row \(row) was selected")
            
            destinationVC.bNewNote = false
            destinationVC.selectedNote = noteEntry
            
            
        }
        
    }
    
    
   /*
    @IBAction func unwindToTitleEntry(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? editNoteViewController,
            titleStr = sourceViewController.noteTitle {
                // Add a new note.
                //let newIndexPath = NSIndexPath(forRow: 0, inSection: 0)
                // notesList.append( TSNotesListClass(  titleStr, noteCount: 0))
                
                //               NSLog("numberOfRowsInSection: \(tableView.numberOfRowsInSection(0))")
                
                notesList.insert(TSNotesListClass(  titleStr, noteCount: 0), atIndex: 0)
                //                let newIndexPath = NSIndexPath(forRow: notesList.count, inSection: 0)
                let newIndexPath = NSIndexPath(forRow: 0, inSection: 0)
                tableView.beginUpdates()
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Top)
                tableView.endUpdates()
                
                //             NSLog("numberOfRowsInSection: \(tableView.numberOfRowsInSection(0))")
                
        }
    }

    */
        
    // Actions
    
    /*
    @IBAction func noteEntrySelectedForEdit(sender: UITapGestureRecognizer) {
        noteSelectedForEdit()
    }
    */
    
    func noteSelectedForEdit(){
        print("User selected note")
    
    }
 
}
