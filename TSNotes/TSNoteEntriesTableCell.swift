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

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
