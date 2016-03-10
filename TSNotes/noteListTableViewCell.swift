//
//  noteListTableViewCell.swift
//  TSNotes
//
//  Created by Jeanne's MacBook on 11/10/15.
//  Copyright © 2015 LCI. All rights reserved.
//

import UIKit

class noteListTableViewCell: UITableViewCell {
    
    // Properties
    @IBOutlet weak var noteTitleField: UILabel!
    @IBOutlet weak var noteModifyDate: UILabel!
    @IBOutlet weak var noteCount: UILabel!
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
