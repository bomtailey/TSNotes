//
//  ViewController.swift
//  TSNotes
//
//  Created by Jeanne's MacBook on 10/23/15.
//  Copyright © 2015 LCI. All rights reserved.
//
//  trying to make this version the new master
//

import UIKit

class ViewController: UIViewController {

    // MARK: Properties
    @IBOutlet weak var dateLabelDisplay: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Fill current date time
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "d MMMM yyyy EEEE h:m a"
        
        dateLabelDisplay.text = dayTimePeriodFormatter.string(from: Date())

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: Actions
    @IBAction func selectDateTimeValue(_ sender: UITapGestureRecognizer) {
        print ("date picker clicked")
    }


}

