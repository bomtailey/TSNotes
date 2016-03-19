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
    var noteName: String?
    var noteText:  String?
    var noteModDateTime: NSDate?
    
//    var noteRecord: NSManagedObject!

//    var selectedNote = TSNote()
    var bNewNote = true
    
    let dayTimePeriodFormatter = NSDateFormatter()
    let originalModTSFormatter = NSDateFormatter()

    var dateString = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        noteTextView?.delegate = self
        
        self.navigationItem.title = noteName
        
        if bNewNote {
            
            // new note entry
            noteTextView.becomeFirstResponder()
            
        } else {
            
            // existing note mod
            
        }
        
        dayTimePeriodFormatter.dateFormat =  "EEEE, d MMMM yyyy h:mm a"
        dateString = dayTimePeriodFormatter.stringFromDate(noteModDateTime!)
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
            
            noteModDateTime = dayTimePeriodFormatter.dateFromString(datetimeDisplay.text!)!
            noteText = noteTextView.text!  ?? ""
        } else
            if segID == "segueToDatePicker" {   // go off to date adjustment view
                
                if let destinationVC = segue.destinationViewController as? handleDatePickerTableViewController{
                    destinationVC.existingDate = noteModDateTime
                }
        }
        
        
    }
    
    // This is unwind from date picker
    @IBAction func unwindFromNoteEntry(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? handleDatePickerTableViewController {
 
            noteModDateTime = sourceViewController.existingDate!
            datetimeDisplay.text = dayTimePeriodFormatter.stringFromDate(noteModDateTime!)
        }
    
    }
    
    // Preserve/restore state data if interrupted
    override func encodeRestorableStateWithCoder(coder: NSCoder) {
        //1
        if let noteName = noteName {
            coder.encodeObject(noteName, forKey: "noteName")
            coder.encodeObject(noteTextView.text, forKey: "noteText")
            coder.encodeObject(noteModDateTime, forKey: "noteModDateTime")
            coder.encodeBool(bNewNote, forKey: "bNewNote")
        }
        
        //2
        super.encodeRestorableStateWithCoder(coder)
    }
    
    override func decodeRestorableStateWithCoder(coder: NSCoder) {
        noteName = coder.decodeObjectForKey("noteName")! as? String
        noteTextView.text = coder.decodeObjectForKey("noteText")! as? String
        noteModDateTime = (coder.decodeObjectForKey("noteModDateTime")! as? NSDate)!
        bNewNote = (coder.decodeObjectForKey("bNewNote")! as? Bool)!

        
        super.decodeRestorableStateWithCoder(coder)
    }

    

}
