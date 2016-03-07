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
    var noteRecord: NSManagedObject!

    var selectedNote = TSNote()
    var bNewNote = true
    
    var noteDateTime = NSDate()
    var modDateTime = NSDate()
    var noteText = ""

    let dayTimePeriodFormatter = NSDateFormatter()
    let originalModTSFormatter = NSDateFormatter()

    var dateString = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        noteTextView?.delegate = self
        noteTextView.becomeFirstResponder()
        
        self.navigationItem.title = noteName
        
        if bNewNote {
            
            // new note entry
            
        } else {
            
            // existing note mod
            
            noteText = (noteRecord.valueForKey("noteText") as? String)!
            noteDateTime = (noteRecord.valueForKey("noteModifiedDateTS") as? NSDate)!
        }
        
        dayTimePeriodFormatter.dateFormat =  "EEEE, d MMMM yyyy h:mm a"
        dateString = dayTimePeriodFormatter.stringFromDate(noteDateTime)
        datetimeDisplay.text = dateString

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

     func textViewDidChange( textView: UITextView) {
        let textLen = textView.text.characters.count
        if textLen > 0 {
            saveButton.enabled = true
        } else {
            saveButton.enabled = false
            
        }
        
    }
    
        func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
            
        let textLen = textView.text.characters.count
 //       let textLen2 =  text.characters.count
        
        if textLen > 0 {
            saveButton.enabled = true
        } else {
            saveButton.enabled = false
            
            }
        
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
            
            noteDateTime = dayTimePeriodFormatter.dateFromString(datetimeDisplay.text!)!
            noteText = noteTextView.text!  ?? ""
        } else
            if segID == "segueToDatePicker" {   // go off to date adjustment view
                
                if let destinationVC = segue.destinationViewController as? handleDatePickerTableViewController{
                    destinationVC.existingDate = modDateTime
                }
        }
        
        
    }
    
    // This is unwind from date picker
    @IBAction func unwindFromNoteEntry(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? handleDatePickerTableViewController {
 
            noteDateTime = sourceViewController.existingDate!
            datetimeDisplay.text = dayTimePeriodFormatter.stringFromDate(noteDateTime)
        }
    
    }
    

}
