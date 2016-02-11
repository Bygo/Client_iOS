//
//  MeetingTimeResponderTableViewCell.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 7/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class MeetingTimeResponderTableViewCell: UITableViewCell {

    @IBOutlet var timeConfirmationView: MeetingTimeResponderView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
