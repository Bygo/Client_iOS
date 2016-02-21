//
//  MenuOptionTableViewCell.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 1/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class MenuOptionTableViewCell: UITableViewCell {
    
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var selectionIndicator:UIView!
    @IBOutlet var selectionIndicatorWidthConstraint: NSLayoutConstraint!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Set the horizontal inset of the cell's text
        textLabel?.frame.origin.x = bounds.size.width*(1.0/3.0) + 16.0 + 16.0 + 25.0 + 8.0
        selectionIndicatorWidthConstraint.constant = bounds.size.width*(1.0/3.0) + 8.0
        
        // If loading the icon, this must be the launch of the app
        // At launch, Rent should always be the first page
        // So if the cell is indexed 0, set this cell to appear selected
        if tag == 0 {
            selectionIndicator.hidden = false
            iconImageView.tintColor = kCOLOR_ONE
            textLabel?.textColor = kCOLOR_ONE
        } else {
            selectionIndicator.hidden = true
        }
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        if highlighted {
            backgroundColor = .lightGrayColor()
        } else {
            backgroundColor = .whiteColor()
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
//        if selected {
//            selectionIndicator.hidden = false
//        } else {
//            selectionIndicator.hidden = true
//        }
    }
    
}
