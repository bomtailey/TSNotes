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
//    @IBOutlet weak var contentView: UIView!
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

 /*
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        
        let color1 = noteTitleField.backgroundColor // Store the color
        let color2 = noteModifyDate.backgroundColor // Store the color
        let color3 = noteCount.backgroundColor // Store the color

        super.setHighlighted(highlighted, animated: animated)
        
        noteTitleField.backgroundColor = color1
        noteModifyDate.backgroundColor = color2
        noteCount.backgroundColor = color3
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        
        let color1 = noteTitleField.backgroundColor // Store the color
        let color2 = noteModifyDate.backgroundColor // Store the color
        let color3 = noteCount.backgroundColor // Store the color
        
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state

        noteTitleField.backgroundColor = color1
        noteModifyDate.backgroundColor = color2
        noteCount.backgroundColor = color3
    }
 
    */

}
