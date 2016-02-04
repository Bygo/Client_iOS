//
//  RentItemReviewTableViewCell.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 3/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class RentItemReviewTableViewCell: UITableViewCell {

    @IBOutlet var ratingImageView: UIImageView!
    @IBOutlet var commenterNameLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var commentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
