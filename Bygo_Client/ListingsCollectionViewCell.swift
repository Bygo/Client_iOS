//
//  ListingsCollectionViewCell.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 4/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class ListingsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var mainImageImageView: UIImageView!
    @IBOutlet var itemTitleLabel: UILabel!
    @IBOutlet var meetingDetailLabel: UILabel!
    @IBOutlet var rentalValueLabel: UILabel!
    @IBOutlet var renterImageView: UIImageView!
    
    override func prepareForReuse() {
        mainImageImageView.image = nil
    }
}
