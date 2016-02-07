//
//  handleDatePickerTableViewController.swift
//  TSNotes
//
//  Created by Jeanne's MacBook on 10/27/15.
//  Copyright © 2015 LCI. All rights reserved.
//

import UIKit

var selectedDateNumeric = NSDate()

let dayTimePeriodFormatter = NSDateFormatter()
let userCalendar = NSCalendar.currentCalendar()
let dateComponents = userCalendar.components([.Year,.Month,.Day,.Hour,.Minute],fromDate: selectedDateNumeric)
let components = NSDateComponents()



class handleDatePickerTableViewController: UITableViewController {
  
    // MARK - properties
    @IBOutlet weak var labelDateDisplay: UILabel!
    @IBOutlet weak var datePickerDisplay: UIDatePicker!
        
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var existingDate: NSDate?

    
    
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
        dayTimePeriodFormatter.dateFormat = "EEEE, d MMMM yyyy   h:mm a"
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

    // This method lets you configure a view controller before it's presented.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
        if saveButton === sender {
            existingDate = selectedDateNumeric
        
        }
    }

    
    // MARK - actions
    
    @IBAction func datePickerAdjusted(sender: UIDatePicker) {
        
        labelDateDisplay.text = dayTimePeriodFormatter.stringFromDate(datePickerDisplay.date)
    }
    
    // Subtract a year
    @IBAction func subtractOneYear(sender: AnyObject) {
        selectedDateNumeric = userCalendar.dateByAddingUnit([.Year], value: -1, toDate: selectedDateNumeric, options: [])!
        setDateDisplay()
    }
  
    // Add a year
    @IBAction func addOneYear(sender: AnyObject) {
        selectedDateNumeric = userCalendar.dateByAddingUnit([.Year], value: 1, toDate: selectedDateNumeric, options: [])!
        setDateDisplay()
    }
    
    // Subtract a month
    @IBAction func subractOneMonth(sender: AnyObject) {
        selectedDateNumeric = userCalendar.dateByAddingUnit([.Month], value: -1, toDate: selectedDateNumeric, options: [])!
        setDateDisplay()
    }
    
    // Add a month
    @IBAction func addOneMonth(sender: AnyObject) {
        selectedDateNumeric = userCalendar.dateByAddingUnit([.Month], value: 1, toDate: selectedDateNumeric, options: [])!
        setDateDisplay()
    }
    
    // Subtract a day

    @IBAction func subtractOneDay(sender: AnyObject) {
        selectedDateNumeric = userCalendar.dateByAddingUnit([.Day], value: -1, toDate: selectedDateNumeric, options: [])!
        setDateDisplay()
    }

    // Add a day
    @IBAction func addOneDay(sender: AnyObject) {
        selectedDateNumeric = userCalendar.dateByAddingUnit([.Day], value: 1, toDate: selectedDateNumeric, options: [])!
        setDateDisplay()
    }
    
    //MARK - local functions
    
    // Set date display label and date picker value
    
    func setDateDisplay (){
        labelDateDisplay.text = dayTimePeriodFormatter.stringFromDate(selectedDateNumeric)
        datePickerDisplay.setDate(selectedDateNumeric, animated: false)
    }
    
    // Navigation
    
    @IBAction func cancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
        
    }

    
    @IBAction func cancelView(sender: AnyObject) {
    }
    


}
