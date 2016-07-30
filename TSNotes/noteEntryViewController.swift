//
//  noteEntryViewController.swift
//  TSNotes
//
//  Created by Jeanne's MacBook on 1/6/16.
//  Copyright © 2016 LCI. All rights reserved.
//

import UIKit
import CoreData



class noteEntryViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
  
    //Properties

    // UI outlets
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var datetimeDisplay: UILabel!
    @IBOutlet weak var titleText: UINavigationItem!
    
    // properties from noteEntriesTableViewController
    var bNewNote = true
    var noteName: String?
    var noteText:  String?
    var noteModDateTime: NSDate?

    
    var bIsRestore = Bool(true)
    
//    var selectedNote = TSNote()
    
    let dayTimePeriodFormatter = NSDateFormatter()
    let originalModTSFormatter = NSDateFormatter()
    let sortableDateOnlyFormatter = NSDateFormatter()
    let displayDateOnlyFormatter = NSDateFormatter()
    let displayTimeOnlyFormatter = NSDateFormatter()

    var dateString = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        noteTextView?.delegate = self
                
        self.navigationItem.title = noteName
        
        if bNewNote {
            
            // new note entry
            noteTextView.becomeFirstResponder()
            noteModDateTime = NSDate()
//            noteRecord.noteText = ""
            
        } else {
            
            // existing note mod
//            noteModDateTime = noteRecord.noteModifiedDateTS
            
        }
        
        dayTimePeriodFormatter.dateFormat =  "EEEE, d MMMM yyyy   h:mm a"
        sortableDateOnlyFormatter.dateFormat = "yyyy.MM.dd"
        displayDateOnlyFormatter.dateFormat = "EEEE MMMM,d yyyy"  // "EEEE, d MMMM yyyy"
        displayTimeOnlyFormatter.dateFormat = "h:mm a"

//        noteName = noteRecord.n
        
//        noteTextView.scrollEnabled = false
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        dateString = dayTimePeriodFormatter.stringFromDate(noteModDateTime!)
        datetimeDisplay.text = dateString
        
        noteTextView.scrollEnabled = true
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
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        
        noteText = noteTextView.text
        
        return true

    }

    // Actions
    
    
    // MARK: - Navigation
    
    
    // Cancel
    @IBAction func cancelEntry(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func timeDisplayLongPress(sender: UILongPressGestureRecognizer) {
        
        if (sender.state == UIGestureRecognizerState.Began) {
        
//            let oldTimeStamp = formatAttributedStringWithHighlights(datetimeDisplay.text!)
           let oldTimeStamp = datetimeDisplay.text!
            
            
            noteTextView.text = "\n\n" + oldTimeStamp + "\n\n" + noteTextView.text
            noteTextView.becomeFirstResponder()

            noteTextView.selectedRange = NSMakeRange(0, 0)

            dateString = dayTimePeriodFormatter.stringFromDate(NSDate())
            datetimeDisplay.text = dateString
            
            saveButton.enabled = true
            
        }
        return
    }
   
    // Save note
//    @IBAction func returnToNoteEntriesView(segue: UIStoryboardSegue, sender: AnyObject?)
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let segID = segue.identifier
        
        if saveButton === sender {  // save the note
            
            noteModDateTime = dayTimePeriodFormatter.dateFromString(datetimeDisplay.text!)!
            noteText = noteTextView.text!  ?? ""

            /*
            noteRecord.noteModifiedDateDay = sortableDateOnlyFormatter.stringFromDate(noteModDateTime!)
            noteRecord.noteModifiedDateTime = displayTimeOnlyFormatter.stringFromDate(noteModDateTime!)
            noteRecord.noteModifiedDateTS = noteModDateTime
            noteRecord.noteText = noteText
             */

        
        } else
            if segID == "segueToDatePicker" {   // go off to date adjustment view
                
                let destinationNavController = segue.destinationViewController as! UINavigationController
                let destinationVC = destinationNavController.topViewController as? handleDatePickerTableViewController
              //  if let destinationVC = segue.destinationViewController as? handleDatePickerTableViewController{
                    destinationVC!.existingDate = noteModDateTime
                //}
        }
        
        
    }
    
    // This is unwind from date picker
    @IBAction func unwindFromNoteEntry(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? handleDatePickerTableViewController {
 
            noteModDateTime = sourceViewController.existingDate!
            datetimeDisplay.text = dayTimePeriodFormatter.stringFromDate(noteModDateTime!)
            saveButton.enabled = true
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
    
    func formatAttributedStringWithHighlights(text: String) -> NSAttributedString {
        
        let mutableString = NSMutableAttributedString(string: text)
        
        let nsText = text as NSString         // convert to NSString be we need NSRange
        let nsTextRange = NSMakeRange(0, nsText.length)
        
            if nsTextRange.length > 0 {       // check for not found
                mutableString.addAttribute(NSBackgroundColorAttributeName, value: UIColor.blueColor(), range: nsTextRange)
            }
        
        
        return mutableString
    }

}
