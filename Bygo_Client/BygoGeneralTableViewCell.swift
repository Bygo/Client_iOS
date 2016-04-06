//
//  BygoGeneralTableViewCell.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 2/4/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class BygoGeneralTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    override func prepareForReuse() {
        backgroundColor = .whiteColor()
        accessoryType = .None
    }
}
