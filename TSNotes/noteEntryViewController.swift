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
    var noteText =  NSMutableAttributedString()
    var noteModDateTime: Date?

    
    var bIsRestore = Bool(true)
    
    let dayTimePeriodFormatter = DateFormatter()
    let originalModTSFormatter = DateFormatter()
    let sortableDateOnlyFormatter = DateFormatter()
    let displayDateOnlyFormatter = DateFormatter()
    let displayTimeOnlyFormatter = DateFormatter()

    var dateString = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        noteTextView?.delegate = self
                
        self.navigationItem.title = noteName
        
        if bNewNote {
            
            // new note entry
            noteTextView.becomeFirstResponder()
            noteModDateTime = Date()
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
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        dateString = dayTimePeriodFormatter.string(from: noteModDateTime!)
        datetimeDisplay.text = dateString
        
        noteTextView.isScrollEnabled = true
        noteTextView.attributedText = noteText


    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 
    // textview function overrides
    
    func textViewShouldBeginEditing(_ aTextView: UITextView) -> Bool
    {
       // moveCursorToStart(noteTextView)
        return true
    }

     func textViewDidChange( _ textView: UITextView) {
        let textLen = textView.text.count
        if textLen > 0 {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
            
        }
        
    }
    
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            
        let textLen = textView.text.count
 //       let textLen2 =  text.characters.count
        
        if textLen > 0 {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
            
            }
        
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        
        noteText.mutableString.setString(noteTextView.text) 
        
        return true

    }

    // Actions
    
    
    // MARK: - Navigation
    
    
    
    
    @IBAction func timeDisplayLongPress(_ sender: UILongPressGestureRecognizer) {
        
        if (sender.state == UIGestureRecognizerState.began) {
        
//            let oldTimeStamp = formatAttributedStringWithHighlights(datetimeDisplay.text!)
           let oldTimeStamp = datetimeDisplay.text!
            
            
            noteTextView.text = "\n\n" + oldTimeStamp + "\n\n" + noteTextView.text
            noteTextView.becomeFirstResponder()

            noteTextView.selectedRange = NSMakeRange(0, 0)

            dateString = dayTimePeriodFormatter.string(from: Date())
            datetimeDisplay.text = dateString
            
            saveButton.isEnabled = true
            
        }
        return
    }
   
    // Save note
//    @IBAction func returnToNoteEntriesView(segue: UIStoryboardSegue, sender: AnyObject?)
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        let segID = segue.identifier
        
        if let sender = sender as? UIBarButtonItem,  saveButton === sender {  // save the note
            
            noteModDateTime = dayTimePeriodFormatter.date(from: datetimeDisplay.text!)!
            
            noteText.mutableString.setString(noteTextView.text!) 
        
        } else
            if segID == "segueToDatePicker" {   // go off to date adjustment view
                
                let destinationNavController = segue.destination as! UINavigationController
                let destinationVC = destinationNavController.topViewController as? handleDatePickerTableViewController
              //  if let destinationVC = segue.destinationViewController as? handleDatePickerTableViewController{
                    destinationVC!.existingDate = noteModDateTime
                //}
        }
        
        
    }
    
    // This is unwind from date picker
    @IBAction func unwindFromNoteEntry(_ sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? handleDatePickerTableViewController {
 
            noteModDateTime = sourceViewController.existingDate! as Date
            datetimeDisplay.text = dayTimePeriodFormatter.string(from: noteModDateTime!)
            saveButton.isEnabled = true
        }
    
    }
    

    // Preserve/restore state data if interrupted
    override func encodeRestorableState(with coder: NSCoder) {
        //1
        if let noteName = noteName {
            coder.encode(noteName, forKey: "noteName")
            coder.encode(noteTextView.text, forKey: "noteText")
            coder.encode(noteModDateTime, forKey: "noteModDateTime")
            coder.encode(bNewNote, forKey: "bNewNote")
        }
        
        //2
        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        noteName = coder.decodeObject(forKey: "noteName")! as? String
        noteTextView.text = coder.decodeObject(forKey: "noteText")! as? String
        noteModDateTime = (coder.decodeObject(forKey: "noteModDateTime")! as? Date)!
        bNewNote = (coder.decodeObject(forKey: "bNewNote")! as? Bool)!

        
        super.decodeRestorableState(with: coder)
    }
    
    func formatAttributedStringWithHighlights(_ text: String) -> NSAttributedString {
        
        let mutableString = NSMutableAttributedString(string: text)
        
        let nsText = text as NSString         // convert to NSString be we need NSRange
        let nsTextRange = NSMakeRange(0, nsText.length)
        
            if nsTextRange.length > 0 {       // check for not found
                mutableString.addAttribute(NSBackgroundColorAttributeName, value: UIColor.blue, range: nsTextRange)
            }
        
        
        return mutableString
    }

}
