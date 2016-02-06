//
//  MeetingLocationProposalTableViewCell.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 4/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class MeetingLocationProposalTableViewCell: UITableViewCell {

    @IBOutlet var locationNameLabel: UILabel!
    @IBOutlet var locationDetailLabel: UILabel!
    @IBOutlet var selectedMarkerButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }

}
