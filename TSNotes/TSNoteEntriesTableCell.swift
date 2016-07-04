//
//  TSNoteEntriesTableCell.swift
//  TSNotes
//
//  Created by Jeanne's MacBook on 11/8/15.
//  Copyright © 2015 LCI. All rights reserved.
//

import UIKit

class TSNoteEntriesTableCell: UITableViewCell {
    
    // MARK: Properties
    @IBOutlet weak var noteEntryDateLabel: UILabel!
    @IBOutlet weak var noteTextView: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


    /*
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        let color1 = noteEntryDateLabel.backgroundColor      // Store the color
        let color2 = noteTextView.backgroundColor      // Store the color
        super.setHighlighted(highlighted, animated: animated)
        noteEntryDateLabel.backgroundColor = color1
        noteTextView.backgroundColor = color2
    }

    
    
    override func setSelected(selected: Bool, animated: Bool) {

        let color1 = noteEntryDateLabel.backgroundColor      // Store the color
        let color2 = noteTextView.backgroundColor      // Store the color

        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        noteEntryDateLabel.backgroundColor = color1
        noteTextView.backgroundColor = color2
    }
    */
 
}
