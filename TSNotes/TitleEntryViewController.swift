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
    @IBOutlet weak var noteTitleText: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // segue variables
    var noteTitle: String?
    var segueListNoteInstance = TSNotesListClass()

    /*
    This value is either passed by `notesListTableController` in `prepareForSegue(_:sender:)`
    or constructed as beginning of adding a new note.
    */
 //   var note: TSNote?
    
    let dayTimePeriodFormatter = NSDateFormatter()

    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        dayTimePeriodFormatter.dateFormat = "EEEE, MMMM d, yyyy h:mm a"
//        noteTitleText.text = dayTimePeriodFormatter.stringFromDate(NSDate())
        
        // Handle the text field’s user input through delegate callbacks.
        noteTitleText.delegate = self
        self.noteTitleText.becomeFirstResponder()

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
    
    /*
    @IBAction func textFieldEditingDidChange(sender: UITextField) {
            let text = noteTitleText.text ?? ""
        avseButton.enabled = text.isEmpty
        
    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        // Enable the Save button only if the text field has a valid Note name.
        checkValidNoteName()
    }
    
    
    func checkValidNoteName() {
        // Disable the Save button if the text field is empty.
        let text = noteTitleText.text ?? ""
        saveButton.enabled = !text.isEmpty
//        saveButton.a
        
    }
    */
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Pass the selected object back to the notesListTableController.
       
        if saveButton === sender {
           // noteTitle = noteTitleText.text
            let nowTime = NSDate()
            segueListNoteInstance.createDateTime = nowTime
            segueListNoteInstance.modifyDateTime = nowTime
            segueListNoteInstance.noteTitle = noteTitleText.text!
        }
        
    }
    
    @IBAction func cancelView(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
 

}
