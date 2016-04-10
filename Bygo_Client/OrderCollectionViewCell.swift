//
//  RequestCollectionViewCell.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 2/4/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class OrderCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    @IBOutlet var offerButton: UIButton!
    
    
    override func prepareForReuse() {
        offerButton.backgroundColor = .clearColor()
        offerButton.setTitleColor(kCOLOR_SIX, forState: .Normal)
        offerButton.setTitleColor(UIColor(red: 64.0/255.0, green: 180.0/255.0, blue: 75.0/255.0, alpha: 0.75), forState: .Highlighted)
        offerButton.titleLabel?.font = UIFont.systemFontOfSize(16.0, weight: UIFontWeightMedium)
    }
}
