//
//  TitleEntryViewController.swift
//  TSNotes
//
//  Created by Jeanne's MacBook on 11/10/15.
//  Copyright © 2015 LCI. All rights reserved.
//

import UIKit

class TitleEntryViewController: UIViewController {
    
    // Properties
    @IBOutlet weak var noteTitleText: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var noteTitle: String?
    
    /*
    This value is either passed by `notesListTableController` in `prepareForSegue(_:sender:)`
    or constructed as beginning of adding a new note.
    */
    var note: TSNote?
    
    let dayTimePeriodFormatter = NSDateFormatter()

    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        dayTimePeriodFormatter.dateFormat = "m/d/yyyy"
        noteTitleText.text = dayTimePeriodFormatter.stringFromDate(NSDate())

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Pass the selected object back to the notesListTableController.
       
        if saveButton === sender {
            noteTitle = noteTitleText.text
        }
        
    }
    

}
