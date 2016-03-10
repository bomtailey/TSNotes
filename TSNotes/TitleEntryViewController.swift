//
//  TitleEntryViewController.swift
//  TSNotes
//
//  Created by Jeanne's MacBook on 11/10/15.
//  Copyright © 2015 LCI. All rights reserved.
//

import UIKit

class TitleEntryViewController: UIViewController, UITextFieldDelegate {
    
    // Properties
    @IBOutlet weak var noteTitleFieldText: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var createDateTimeLabel: UILabel!
    
    // segue variables
    var noteTitleField: String?
    var noteCreateDate: NSDate?
    var segueListNoteInstance = TSNoteBaseClass()
    var newTitleRequest = Bool(true)

    /*
    This value is either passed by `NoteBaseTableController` in `prepareForSegue(_:sender:)`
    or constructed as beginning of adding a new note.
    */
 //   var note: TSNote?
    
    let dayTimePeriodFormatter = NSDateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        dayTimePeriodFormatter.dateFormat = "EEEE, MMMM d, yyyy h:mm a"
//        noteTitleFieldText.text = dayTimePeriodFormatter.stringFromDate(NSDate())
        
        // Handle the text field’s user input through delegate callbacks.
        noteTitleFieldText.delegate = self
        noteTitleFieldText.becomeFirstResponder()
        self.title = "New Note Title"
        // If not a new note title, this is an update
        if newTitleRequest {
            
            createDateTimeLabel.text = ""
        } else {
            noteTitleFieldText.text = noteTitleField
            dayTimePeriodFormatter.dateFormat =  "EEEE MM/d/yy h:mm a"
            createDateTimeLabel.text = "Date Created: " +
                dayTimePeriodFormatter.stringFromDate(noteCreateDate!)

            self.title = "Modify Note Title"
       }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    
    // MARK: UITextFieldDelegate 
    
    /*
    @objc func textFieldDidBeginEditing(textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.enabled = false
    }
    
     func textFieldShouldEndEditing (textField: UITextField) {
        
    }
    
    */
    
    func textFieldShouldClear (textField: UITextField) -> Bool {

        saveButton.enabled = false
        return true
    }

    
    /*
    func textField(textField: UITextField,
        shouldChangeCharactersInRange range: NSRange,
        replacementString string: String)
        -> Bool
    {
        if string.characters.count > 0 {
            saveButton.enabled = true
        }
        
        return true
    }
*/
    
    // Disable save button if title field is empty
    @IBAction func textFieldEditingDidChange(sender: UITextField) {
        let text = noteTitleFieldText.text ?? ""
        saveButton.enabled = !text.isEmpty
    }
    
    /*
    func textFieldDidEndEditing(textField: UITextField) {
        // Enable the Save button only if the text field has a valid Note name.
        checkValidNoteName()
    }
    
    
    func checkValidNoteName() {
        // Disable the Save button if the text field is empty.
        let text = noteTitleFieldText.text ?? ""
        saveButton.enabled = !text.isEmpty
//        saveButton.a
        
    }
    */
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Pass the selected object back to the NoteBaseTableController.
       
        if saveButton === sender {
           // noteTitleField = noteTitleFieldText.text
            let nowTime = NSDate()
            if newTitleRequest {
                segueListNoteInstance.createDateTime = nowTime
            }
            segueListNoteInstance.modifyDateTime = nowTime
            segueListNoteInstance.noteTitleField = noteTitleFieldText.text!
        }
        
    }
    
    @IBAction func cancelView(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
 

}
