//
//  noteEntryViewController.swift
//  TSNotes
//
//  Created by Jeanne's MacBook on 1/6/16.
//  Copyright © 2016 LCI. All rights reserved.
//

import UIKit



class noteEntryViewController: UIViewController, UITextViewDelegate {
  
    //Properties

    // UI outlets
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var datetimeDisplay: UILabel!
    
    
    // properties from noteEntriesTableViewController
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
        dayTimePeriodFormatter.dateFormat =  " h:mm a"
        
        if bNewNote {
            
            // new note entry
            selectedNote.modifyDateTime = noteDateTime
            selectedNote.createDateTime = noteDateTime
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
    
    @IBAction func cancelEntry(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)    }
    
    /*

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
