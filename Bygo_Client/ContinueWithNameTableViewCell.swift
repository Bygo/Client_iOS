//
//  ContinueWithNameTableViewCell.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 1/3/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class ContinueWithNameTableViewCell: UITableViewCell {
    
    @IBOutlet var continueWithLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var newNameLabel: UILabel!

    func updateName(newName: String) {
        newNameLabel.text = "\"\(newName)\""
        newNameLabel.alpha = 0.0
        newNameLabel.layoutIfNeeded()
        
        UIView.animateWithDuration(0.5, animations: {
            self.nameLabel.alpha = 0.0
            self.newNameLabel.alpha = 1.0
            }, completion: {
                (complete:Bool) in
                if complete {
                    self.nameLabel.text = "\"\(newName)\""
                    self.nameLabel.layoutIfNeeded()
                    self.nameLabel.alpha = 1.0
                    self.newNameLabel.alpha = 0.0
                }
        })
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
