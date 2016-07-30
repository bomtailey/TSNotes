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
    var noteCreateDate: NSDate?
    var noteBaseRecord: NoteBase!
    var managedObjectContext: NSManagedObjectContext!


    var segueListNoteInstance: NoteBase!
    var savedNoteBase = [NSManagedObject]()

    var newTitleRequest = Bool(true)

    /*
    This value is either passed by `NoteBaseTableController` in `prepareForSegue(_:sender:)`
    or constructed as beginning of adding a new note.
    */

    
    let dayTimePeriodFormatter = NSDateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        //        dayTimePeriodFormatter.dateFormat = "EEEE, MMMM d, yyyy h:mm a"
//        noteTitleFieldText.text = dayTimePeriodFormatter.stringFromDate(NSDate())
        
        // Handle the text field’s user input through delegate callbacks.
        noteTitleFieldText.delegate = self
        
        noteTitleFieldText.becomeFirstResponder()
        
        // If not a new note title, this is an update
        if newTitleRequest {
            self.title = "New Note Title"
           
            createDateTimeLabel.text = ""

        } else {
            noteTitleFieldText.text = noteBaseRecord.noteName
            dayTimePeriodFormatter.dateFormat =  "EEEE MM/d/yy h:mm a"
            createDateTimeLabel.text = "Date Created: " +
                dayTimePeriodFormatter.stringFromDate(noteBaseRecord.createDateTS!)

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
    
    
    // Pass the data back to the NoteBaseTableController.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       
        if saveButton === sender {
           // noteTitleField = noteTitleFieldText.text
            let nowTime = NSDate()

            if newTitleRequest {
/*                let entity =  NSEntityDescription.entityForName("NoteBase", inManagedObjectContext: managedObjectContext)
                 segueListNoteInstance = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedObjectContext) as! NoteBase
                

                segueListNoteInstance.setValue(nowTime, forKey: "createDateTS")
                segueListNoteInstance.setValue(nowTime, forKey: "modifyDateTS")
                segueListNoteInstance.setValue(noteTitleFieldText.text!, forKey: "noteName")
                segueListNoteInstance.setValue(0, forKey:"noteCount")
 */

                noteBaseRecord.setValue(nowTime, forKey: "createDateTS")
//                noteBaseRecord.setValue(nowTime, forKey: "modifyDateTS")
//                noteBaseRecord.setValue(noteTitleFieldText.text!, forKey: "noteName")
                noteBaseRecord.setValue(0, forKey:"noteCount")

            }
                
 
            noteBaseRecord.setValue(nowTime, forKey: "modifyDateTS")
            noteBaseRecord.setValue(noteTitleFieldText.text!, forKey: "noteName")
            
            

            // Try save managed context
            do {
                try managedObjectContext.save()
                //5
 //               if newTitleRequest {
 //                   savedNoteBase.append(segueListNoteInstance)
//                }
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
            

        }
        
    }
    
    @IBAction func cancelView(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
 

}
