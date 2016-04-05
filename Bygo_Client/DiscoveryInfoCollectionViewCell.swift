//
//  CreateNewListingCollectionViewCell.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 1/4/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class DiscoveryInfoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
 
    override var highlighted: Bool {
        get {
            return super.highlighted
        }
        set {
            if newValue {
                super.highlighted = true
                alpha = 0.75
            } else if newValue == false {
                super.highlighted = false
                alpha = 1.0
            }
        }
    }
}
