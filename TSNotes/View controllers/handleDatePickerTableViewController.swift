//
//  handleDatePickerTableViewController.swift
//  TSNotes
//
//  Created by Jeanne's MacBook on 10/27/15.
//  Copyright © 2015 LCI. All rights reserved.
//

import UIKit

var selectedDateNumeric = Date()

let dayTimePeriodFormatter = DateFormatter()
let userCalendar = Calendar.current
let dateComponents = (userCalendar as NSCalendar).components([.year,.month,.day,.hour,.minute],from: selectedDateNumeric)
let components = DateComponents()



class handleDatePickerTableViewController: UITableViewController {
  
    // MARK - properties
    @IBOutlet weak var datePickerDisplay: UIDatePicker!
    @IBOutlet weak var labelDateDisplay: UILabel!
        
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var existingDate: Date?

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    /*
    This value is either passed by `addModifyNoteViewController` in `prepareForSegue(_:sender:)`
        @IBAction func subtractOneYear(sender: AnyObject) {
        }
    or constructed as part of modifying the existing date.
    */
        
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // capture date from note edit scene
         selectedDateNumeric =  existingDate!

        
        // Fill current date time
        dayTimePeriodFormatter.dateFormat = "d MMMM yyyy EEEE   h:mm a"
        setDateDisplay ()
        
        /*
        // set up reference to date picker
        UIDatePicker.
        
        self.myDatePicker addTarget:self action:@selector(datePickerAction:)
        forControlEvents:UIControlEventValueChanged
        */

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

 
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


    // MARK: - Navigation

    // This returns to noteEntryViewController with possibly changed date
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if let sender = sender as? UIBarButtonItem,  saveButton === sender {
            existingDate = selectedDateNumeric        
        }
    }

    
    // MARK - actions
    
    @IBAction func datePickerChanged(_ sender: AnyObject) {
        
        selectedDateNumeric = datePickerDisplay.date
        labelDateDisplay.text = dayTimePeriodFormatter.string(from: selectedDateNumeric)
    }
    
    // Subtract a year
    @IBAction func subtractOneYear(_ sender: AnyObject) {
        selectedDateNumeric = (userCalendar as NSCalendar).date(byAdding: [.year], value: -1, to: selectedDateNumeric, options: [])!
        setDateDisplay()
    }
  
    // Add a year
    @IBAction func addOneYear(_ sender: AnyObject) {
        selectedDateNumeric = (userCalendar as NSCalendar).date(byAdding: [.year], value: 1, to: selectedDateNumeric, options: [])!
        setDateDisplay()
    }
    
    // Subtract a month
    @IBAction func subractOneMonth(_ sender: AnyObject) {
        selectedDateNumeric = (userCalendar as NSCalendar).date(byAdding: [.month], value: -1, to: selectedDateNumeric, options: [])!
        setDateDisplay()
    }
    
    // Add a month
    @IBAction func addOneMonth(_ sender: AnyObject) {
        selectedDateNumeric = (userCalendar as NSCalendar).date(byAdding: [.month], value: 1, to: selectedDateNumeric, options: [])!
        setDateDisplay()
    }
    
    // Subtract a day

    @IBAction func subtractOneDay(_ sender: AnyObject) {
        selectedDateNumeric = (userCalendar as NSCalendar).date(byAdding: [.day], value: -1, to: selectedDateNumeric, options: [])!
        setDateDisplay()
    }

    // Add a day
    @IBAction func addOneDay(_ sender: AnyObject) {
        selectedDateNumeric = (userCalendar as NSCalendar).date(byAdding: [.day], value: 1, to: selectedDateNumeric, options: [])!
        setDateDisplay()
    }
    
    //MARK - local functions
    
    // Set date display label and date picker value
    
    func setDateDisplay (){
        labelDateDisplay.text = dayTimePeriodFormatter.string(from: selectedDateNumeric)
        datePickerDisplay.setDate(selectedDateNumeric, animated: false)
    }
    
    @IBAction func nowButton(_ sender: UIButton) {
        selectedDateNumeric = Date()
        setDateDisplay()
  }
    
    
    // Navigation
    
    @IBAction func cancelButton(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    
    @IBAction func cancelView(_ sender: AnyObject) {
    }
    


}
