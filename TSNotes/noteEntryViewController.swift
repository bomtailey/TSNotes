//
//  noteEntryViewController.swift
//  TSNotes
//
//  Created by Jeanne's MacBook on 1/6/16.
//  Copyright © 2016 LCI. All rights reserved.
//

import UIKit
import CoreData



class noteEntryViewController: UIViewController, UITextViewDelegate {
  
    //Properties

    // UI outlets
    @IBOutlet weak var datetimeDisplay: UILabel!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    // properties from noteEntriesTableViewController
    var noteBaseRecord: NSManagedObject!
    var noteName: String?
    var selectedNote = TSNote()
    var bNewNote = true
    
    var noteDateTime = NSDate()
    var noteText = ""
    
    let dayTimePeriodFormatter = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        noteTextView?.delegate = self
        
        self.navigationItem.title = noteName
        dayTimePeriodFormatter.dateFormat =  "EEEE, MMMM d, yyyy h:mm a"  //" h:mm a"
        
        if bNewNote {
            
            // new note entry
            selectedNote.modifyDateTime = noteDateTime
            
       //     selectedNote.createDateTime = noteDateTime
       //     noteTextView.becomeFirstResponder()
            
            
        } else {
            
            // existing note mod
            
            noteDateTime = selectedNote.modifyDateTime
            noteText = selectedNote.noteText
        }
        
        datetimeDisplay.text = dayTimePeriodFormatter.stringFromDate(noteDateTime)
        noteTextView.text = noteText

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    // textview function overrides
    
    func textViewShouldBeginEditing(aTextView: UITextView) -> Bool
    {
       // moveCursorToStart(noteTextView)
        return true
    }

    
    // MARK: - Navigation
    
    
    // Cancel
    @IBAction func cancelEntry(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
   
    // Save note
//    @IBAction func returnToNoteEntriesView(segue: UIStoryboardSegue, sender: AnyObject?)
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let segID = segue.identifier
        
        if saveButton === sender {  // save the note
            
     //       noteDateTime = dayTimePeriodFormatter.dateFromString(datetimeDisplay.text!)!
            noteText = noteTextView.text!  ?? ""
        } else
            if segID == "segueToDatePicker" {   // go off to date adjustment view
                
                if let destinationVC = segue.destinationViewController as? handleDatePickerTableViewController{
                    destinationVC.existingDate = noteDateTime
                }
        }
        
        
    }
    
    @IBAction func unwindFromNoteEntry(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? handleDatePickerTableViewController {
            noteDateTime = sourceViewController.existingDate!
        }
    
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    /*
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if saveButton === sender {
            noteDateTime = NSDate()
            noteText = noteTextView.text!
        }
        
    }
    */
    

}
