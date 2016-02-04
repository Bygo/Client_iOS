//
//  MenuOptionTableViewCell.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 1/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class MenuOptionTableViewCell: UITableViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Set the horizontal inset of the cell's text
        textLabel?.frame.origin.x = bounds.size.width*(1.0/3.0) + 16.0
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        if highlighted {
            backgroundColor = .lightGrayColor()
        } else {
            backgroundColor = .whiteColor()
        }
    }
    
}
