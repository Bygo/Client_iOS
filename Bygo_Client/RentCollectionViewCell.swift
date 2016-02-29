//
//  RentCollectionViewCell.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 3/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class RentCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var mainImageImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var ratingImageView: UIImageView!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var noRatingLabel: UILabel!
    @IBOutlet var rentalRateLabel: UILabel!
    @IBOutlet var timeFrameLabel: UILabel!
    @IBOutlet var markerImageView: UIImageView!
    
    
    override func prepareForReuse() {
        mainImageImageView.image = nil
    }
}
