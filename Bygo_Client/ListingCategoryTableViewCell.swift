//
//  ListingCategoryTableViewCell.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 1/3/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class ListingCategoryTableViewCell: UITableViewCell {

    @IBOutlet var background: UIView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.font = UIFont.systemFontOfSize(16.0)
        textLabel?.textColor = .blackColor()
        textLabel?.backgroundColor = .clearColor()
        backgroundColor = .whiteColor()
        
        background?.backgroundColor = kCOLOR_FIVE
        background?.alpha = 0.0
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    private let kANIMATION_DURATION = 0.15

    override func setSelected(selected: Bool, animated: Bool) {
//         super.setSelected(selected, animated: animated)
//         Configure the view for the selected state
        if selected {
            UIView.animateWithDuration(kANIMATION_DURATION, animations: {
                self.background?.alpha = 1.0
                self.textLabel?.textColor = .whiteColor()
            })
        } else {
            UIView.animateWithDuration(kANIMATION_DURATION, animations: {
                self.background?.alpha = 0.0
                self.textLabel?.textColor = .blackColor()
            })
        }
    }

    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
//        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            
            UIView.animateWithDuration(kANIMATION_DURATION, animations: {
                self.background?.alpha = 1.0
                self.textLabel?.textColor = .whiteColor()
            })
            
            
        } else {
            UIView.animateWithDuration(kANIMATION_DURATION, animations: {
                self.background?.alpha = 0.0
                self.textLabel?.textColor = .blackColor()
            })
        }
    }
}

