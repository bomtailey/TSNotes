//
//  TitleEntryViewController.swift
//  TSNotes
//
//  Created by Jeanne's MacBook on 11/10/15.
//  Copyright © 2015 LCI. All rights reserved.
//

import UIKit
import CoreData


class TitleEntryViewController: UIViewController, UITextFieldDelegate {
    
    // Properties
    @IBOutlet weak var noteTitleFieldText: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var createDateTimeLabel: UILabel!
    
    // segue variables
    var noteTitleField: String?
    var noteCreateDate: Date?
    var noteBaseRecord: NoteBase!
    var managedObjectContext: NSManagedObjectContext!


    var segueListNoteInstance: NoteBase!
    var savedNoteBase = [NSManagedObject]()

    var newTitleRequest = Bool(true)

    /*
    This value is either passed by `NoteBaseTableController` in `prepareForSegue(_:sender:)`
    or constructed as beginning of adding a new note.
    */

    
    let dayTimePeriodFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        //        dayTimePeriodFormatter.dateFormat = "EEEE, MMMM d, yyyy h:mm a"
//        noteTitleFieldText.text = dayTimePeriodFormatter.stringFromDate(NSDate())
        
        // Handle the text field’s user input through delegate callbacks.
        noteTitleFieldText.delegate = self
        
        noteTitleFieldText.becomeFirstResponder()
        
        // Don't konw why this should be needed because it's specified in storyboard and it used to work
        //noteTitleFieldText.autocapitalizationType = .words
        
        // If not a new note title, this is an update
        if newTitleRequest {
            self.title = "New Note Title"
           
            createDateTimeLabel.text = ""

        } else {
            noteTitleFieldText.text = noteBaseRecord.noteName
            dayTimePeriodFormatter.dateFormat =  "d MMMM yyyy EEEE h:mm a"
            createDateTimeLabel.text = "Date Created: " +
                dayTimePeriodFormatter.string(from: noteBaseRecord.createDateTS! as Date)

            self.title = "Modify Note Title"
       }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
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
    
    func textFieldShouldClear (_ textField: UITextField) -> Bool {

        saveButton.isEnabled = false
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
    @IBAction func textFieldEditingDidChange(_ sender: UITextField) {
        let text = noteTitleFieldText.text ?? ""
        saveButton.isEnabled = !text.isEmpty
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
    
    
    // Pass the data back to the NoteBaseTableController.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if let sender = sender as? UIBarButtonItem, saveButton === sender {
           // noteTitleField = noteTitleFieldText.text
            let nowTime = Date()

            if newTitleRequest {
                
                let entity =  NSEntityDescription.entity(forEntityName: "NoteBase", in:managedObjectContext)
                noteBaseRecord = NSManagedObject(entity: entity!, insertInto: managedObjectContext) as? NoteBase

                noteBaseRecord.setValue(nowTime, forKey: "createDateTS")
                noteBaseRecord.setValue(0, forKey:"noteCount")
            }
 
            noteBaseRecord.setValue(nowTime, forKey: "modifyDateTS")
            noteBaseRecord.setValue(nowTime, forKey: "latestNoteDate") 
            noteBaseRecord.setValue(noteTitleFieldText.text!, forKey: "noteName")

            // Try save managed context
            do {
                try managedObjectContext.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
            

        }
        
    }
    
    @IBAction func cancelView(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
 

}
