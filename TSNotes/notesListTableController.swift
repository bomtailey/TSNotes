//
//  notesListTableController.swift - this is the table listing all the notes
//  TSNotes
//
//  Created by Jeanne's MacBook on 11/6/15.
//  Copyright © 2015 LCI. All rights reserved.
//

import UIKit
import CoreData

class notesListTableController: UITableViewController {
    
    // MARK: Properties
    
    var notesList = [TSNotesListClass]()
    var savedNotesList = [NSManagedObject]()
    
    var titleString = ""
    var segueListNoteInstance = TSNotesListClass()
    
    var selectedCreateDate = NSDate()
    
    let dayTimePeriodFormatter = NSDateFormatter()
    // dayTimePeriodFormatter.dateFormat = "EEEE, d MMMM yyyy h:m a"


    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        dayTimePeriodFormatter.dateFormat =  "EEEE, MMMM d, yyyy h:mm a"
        
        //loadSampleNotes()
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem()
        
        // Show location of database
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        print("App Path: \(dirPaths)")
    }
    
    func loadSampleNotes() {
        
        let TSNote1 = TSNotesListClass(  "This is test subject 1 - Nov 5", createDate: "Nov 5, 2015 10:22 AM",
                noteCount: 12)
        let TSNote2 = TSNotesListClass(  "This is test subject 2 - Nov 25", createDate: "Nov 25, 2015 12:22 PM", noteCount: 5)
        let TSNote3 = TSNotesListClass( "This is test subject 3 - Dec 1" , createDate: "Dec 1, 2015 1:55 AM")
        
        notesList += [ TSNote1, TSNote2, TSNote3]
        
        //let dayTimePeriodFormatter = NSDateFormatter()
       //dayTimePeriodFormatter.dateFormat = "m/d/yyyy h:m a"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        
        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //2
        let fetchRequest = NSFetchRequest(entityName: "NotesList")
        
        // Add Sort Descriptor
        let sortDescriptor = NSSortDescriptor(key: "modifyDateTS", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        
        //3
        do {
            let results =
            try managedContext!.executeFetchRequest(fetchRequest)
            savedNotesList = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows
        return savedNotesList.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "noteListTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
            as! noteListTableViewCell

    // Configure the cell...
        
//        let note = notesList[indexPath.row]
        let note = savedNotesList[indexPath.row]
        
        if let noteModifyDate = note.valueForKey("modifyDateTS") as! NSDate?
 {
            cell.noteTitle.text = note.valueForKey("noteName") as? String
 //           let noteModifyDate = note.valueForKey("modifyDateTS") as! NSDate
            cell.noteModifyDate.text = dayTimePeriodFormatter.stringFromDate(noteModifyDate)
 //       cell.noteCreateDate.text = dayTimePeriodFormatter.stringFromDate(note.createDateTime)
        }

    return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        
        return true
    }


    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            // Delete the row from the data source
 //           tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            let NotesList = savedNotesList[indexPath.row]
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            let managedContext = appDelegate.managedObjectContext
            
            managedContext!.deleteObject(NotesList)
            
            do {
                try managedContext!.save()
            } catch {
                let saveError = error as NSError
                print(saveError)
            }

            savedNotesList.removeAtIndex(indexPath.row)
  //          tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
  //                  navigationItem.leftBarButtonItem?.
            
            tableView.reloadData()


        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        print("You selected cell #\(indexPath.row+1)!")
    }

    
    
    let segueIndentifier = "showNoteEntriesSegue"
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let sID = segue.identifier
  //      if segue.identifier == segueIndentifier {
            if sID == segueIndentifier {
            
            if let destination = segue.destinationViewController as? noteEntriesTableViewController {
                
                if let noteIndex = tableView.indexPathForSelectedRow?.row {
                    
                //    let note = notesList[noteIndex]
                    let note = savedNotesList[noteIndex]

                    destination.noteCreateDate = (note.valueForKey("createDateTS") as! NSDate?)!
                    destination.noteName = (note.valueForKey("noteName")  as! String?)!
 //                   destination.noteName = note.noteTitle
                }
            }
        }
    }
    
    
    
    @IBAction func unwindToTitleEntry(sender: UIStoryboardSegue) {
         let sourceViewController = sender.sourceViewController as? TitleEntryViewController,
            segueListNoteInstance = sourceViewController!.segueListNoteInstance
 
        // Add a new note.
                //let newIndexPath = NSIndexPath(forRow: 0, inSection: 0)
            // notesList.append( TSNotesListClass(  titleStr, noteCount: 0))
                
 //               NSLog("numberOfRowsInSection: \(tableView.numberOfRowsInSection(0))")
                
          //      notesList.insert(TSNotesListClass(  titleStr, noteCount: 0), atIndex: 0)
//                let newIndexPath = NSIndexPath(forRow: notesList.count, inSection: 0)
        
  //          savedNotesList.append( segueListNoteInstance)
        
        /*
        let newIndexPath = NSIndexPath(forRow: 0, inSection: 0)
            tableView.beginUpdates()
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Top)
            tableView.endUpdates()
        */
        
   //             NSLog("numberOfRowsInSection: \(tableView.numberOfRowsInSection(0))")
        
        
        saveNote(segueListNoteInstance)
        tableView.reloadData()

        
    }
    
    func saveNote(newNoteInfo: TSNotesListClass) {
        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //2
        
        
        let entity =  NSEntityDescription.entityForName("NotesList",
            inManagedObjectContext:managedContext!)
        
        let note = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext: managedContext)
        
        //3
        
        
        note.setValue(newNoteInfo.modifyDateTime, forKey: "modifyDateTS")
        note.setValue(newNoteInfo.createDateTime, forKey: "createDateTS")
        note.setValue(newNoteInfo.noteTitle, forKey: "noteName")
        
        //4
        do {
            try managedContext!.save()
            //5
            savedNotesList.append(note)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
    }

}
